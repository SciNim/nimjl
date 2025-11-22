## System Image Support for nimjl
##
## This module provides functionality to create and load custom Julia system images.
## System images allow you to:
## - Precompile Julia code into a binary
## - Reduce startup time by avoiding recompilation
## - Distribute applications without embedding source code
## - Include custom packages in the system image

import ./types
import ./errors
import ./cores
import ./private/jlcores
import ./config
import std/[os, strformat, macros, strutils, osproc, sequtils]

type SysImageConfig* = object ## Configuration for system image creation
  imagePath*: string ## Path where system image will be saved
  baseImage*: string ## Base system image to build on (empty = default)
  packages*: seq[string] ## Packages to include
  juliaFiles*: seq[string] ## Julia source files to compile into image (runtime paths)
  juliaCode*: seq[tuple[filename: string, content: string]] ## Julia source code embedded at compile-time
  cpuTarget*: string ## CPU target (e.g., "native", "x86-64")
  optimize*: int ## Optimization level (0-3)
  checkBounds*: bool ## Include bounds checking
  compileMin*: bool ## Minimal compilation (faster build)

proc defaultSysImageConfig*(): SysImageConfig =
  ## Create default system image configuration
  result = SysImageConfig(
    imagePath: getCurrentDir() / "custom_sys.so",
    baseImage: "",
    packages: @[],
    juliaFiles: @[],
    juliaCode: @[],
    cpuTarget: "native",
    optimize: 2,
    checkBounds: false,
    compileMin: false,
  )

proc expandJuliaFiles(paths: openArray[string]): seq[string] =
  ## Expand paths to include all .jl files from directories
  ## Supports both individual files and directories
  result = @[]

  for path in paths:
    if fileExists(path):
      # It's a file, add it directly
      if path.endsWith(".jl"):
        result.add(path)
      else:
        echo &"Warning: Skipping non-.jl file: {path}"
    elif dirExists(path):
      # It's a directory, add all .jl files recursively
      for file in walkDirRec(path):
        if file.endsWith(".jl"):
          result.add(file)
    else:
      raise newException(ValueError, &"Path not found: {path}")

proc validateSysImageConfig(config: SysImageConfig) =
  ## Validate system image configuration
  if config.imagePath.len == 0:
    raise newException(ValueError, "System image path cannot be empty")

  let imageDir = config.imagePath.parentDir()
  if imageDir.len > 0 and not dirExists(imageDir):
    raise newException(ValueError, &"Directory does not exist: {imageDir}")

  # Validate that paths exist (files or directories)
  for path in config.juliaFiles:
    if not fileExists(path) and not dirExists(path):
      raise newException(ValueError, &"Julia file or directory not found: {path}")

proc createSysImage*(config: SysImageConfig) =
  ## Create a Julia system image with custom packages and code
  ##
  ## Example:
  ## ```nim
  ## var cfg = defaultSysImageConfig()
  ## cfg.imagePath = "my_app.so"
  ## cfg.packages = @["DataFrames", "Plots", "DifferentialEquations"]
  ## cfg.juliaFiles = @["app_init.jl", "core_functions.jl"]
  ## createSysImage(cfg)
  ## ```

  validateSysImageConfig(config)

  # Check if Julia is initialized (we need it to create the image)
  let wasInitialized = jl_is_initialized().bool
  if not wasInitialized:
    jl_init()

  try:
    # Build the precompile script
    var precompileScript = ""

    # Add packages
    if config.packages.len > 0:
      precompileScript.add "# Loading packages\n"
      for pkg in config.packages:
        precompileScript.add &"using {pkg}\n"
      precompileScript.add "\n"

    # Add custom Julia files (from disk, expanding directories)
    let expandedFiles = expandJuliaFiles(config.juliaFiles)
    if expandedFiles.len > 0:
      precompileScript.add "# Including Julia files\n"
      for jlFile in expandedFiles:
        let absPath = jlFile.absolutePath()
        precompileScript.add &"include(\"{absPath}\")\n"
      precompileScript.add "\n"

      # Add embedded Julia code (compile-time embedded)
      if config.juliaCode.len > 0:
        precompileScript.add "# Embedded Julia code\n"
        for (filename, code) in config.juliaCode:
          precompileScript.add &"# From: {filename}\n"
          precompileScript.add code
          precompileScript.add "\n\n"

      # Save precompile script
    let precompileFile = getTempDir() / "nimjl_precompile.jl"
    writeFile(precompileFile, precompileScript)

    echo &"Creating system image at: {config.imagePath}"
    echo &"Precompile script saved to: {precompileFile}"

    # Use PackageCompiler to create system image
    discard jlEval("using Pkg; Pkg.add(\"PackageCompiler\")")
    discard jlEval("using PackageCompiler")

    # Build the command
    let packagesList = config.packages.mapIt("\"" & it & "\"").join(", ")
    var createCmd =
      &"""
PackageCompiler.create_sysimage(
  [{packagesList}];
  sysimage_path = "{config.imagePath}",
  precompile_execution_file = "{precompileFile}",
  cpu_target = "{config.cpuTarget}",
"""

    if config.baseImage.len > 0:
      createCmd.add &"  base_sysimage = \"{config.baseImage}\",\n"

    createCmd.add &"  filter_stdlibs = {not config.checkBounds},\n"
    createCmd.add ")\n"

    echo "Building system image (this may take several minutes)..."
    let result = jlEval(createCmd)
    enhancedJlExceptionHandler("creating system image")

    if fileExists(config.imagePath):
      echo &"System image created successfully: {config.imagePath}"
      echo &"Size: {getFileSize(config.imagePath) div 1024 div 1024} MB"
    else:
      raise newException(JlError, "System image creation failed - file not found")
  finally:
    # Clean up temp file
    let precompileFile = getTempDir() / "nimjl_precompile.jl"
    if fileExists(precompileFile):
      removeFile(precompileFile)

proc jlVmInitWithImage*(imagePath: string, nthreads: int = 1) =
  ## Initialize Julia VM with a custom system image
  ##
  ## This allows you to load precompiled code and avoid re-compilation.
  ## The image must have been created with createSysImage.
  ##
  ## Example:
  ## ```nim
  ## jlVmInitWithImage("my_app.so")
  ## # Julia is now initialized with your custom code
  ## let result = Julia.myCustomFunction(42)
  ## ```

  if jl_is_initialized().bool:
    raise newException(JlInitError, "Julia VM is already initialized. Cannot load custom image.")

  if not fileExists(imagePath):
    raise newException(JlError, &"System image not found: {imagePath}")

  echo &"Initializing Julia VM with custom image: {imagePath}"

  # Set number of threads
  if nthreads > 1:
    putEnv("JULIA_NUM_THREADS", $nthreads)

  # Load the custom system image
  let absImagePath = imagePath.absolutePath()
  let juliaBinDir = JuliaPath / "bin"

  jl_init_with_image(juliaBinDir.cstring, absImagePath.cstring)

  if not jl_is_initialized().bool:
    raise newException(JlInitError, "Failed to initialize Julia VM with custom image")

  echo "Julia VM initialized successfully with custom image"

proc jlVmInitWithImageThreaded*(imagePath: string, nthreads: int) =
  ## Initialize Julia VM with custom image and threading support
  ##
  ## Note: Requires Julia 1.9+ and specific Julia build
  ## Falls back to regular init if threading version not available

  if jl_is_initialized().bool:
    raise newException(JlInitError, "Julia VM is already initialized")

  if not fileExists(imagePath):
    raise newException(JlError, &"System image not found: {imagePath}")

  putEnv("JULIA_NUM_THREADS", $nthreads)

  let absImagePath = imagePath.absolutePath()
  let juliaBinDir = JuliaPath / "bin"

  # For now, just use regular init
  # The threading version requires special Julia builds
  echo "Note: Using standard init (threading init requires special Julia build)"
  jl_init_with_image(juliaBinDir.cstring, absImagePath.cstring)

# Convenience proc for init with system image
proc initWithSysImage*(imagePath: string, nthreads: int = 1) =
  ## Initialize Julia with a custom system image
  ## This is a convenience wrapper around jlVmInitWithImage
  jlVmInitWithImage(imagePath, nthreads)

# Helper to create comprehensive system images
proc createAppSysImage*(
    outputPath: string,
    packages: openArray[string],
    sourceFiles: openArray[string] = [],
    sourceDirs: openArray[string] = [],
    optimize: int = 2
) =
  ## Convenient helper to create an application system image
  ##
  ## Supports both individual files and directories.
  ## Directories are scanned recursively for .jl files.
  ##
  ## Example:
  ## ```nim
  ## createAppSysImage(
  ##   "myapp.so",
  ##   packages = ["DataFrames", "Plots", "CSV"],
  ##   sourceFiles = ["src/init.jl"],  # Individual files
  ##   sourceDirs = ["src/modules/"],  # All .jl files in directory
  ##   optimize = 3
  ## )
  ## ```

  var config = defaultSysImageConfig()
  config.imagePath = outputPath
  config.packages = @packages

  # Combine files and directories
  var allPaths: seq[string] = @[]
  allPaths.add(@sourceFiles)
  allPaths.add(@sourceDirs)
  config.juliaFiles = allPaths

  config.optimize = optimize

  createSysImage(config)

# Information about current system image
proc currentSysImageInfo*(): tuple[path: string, size: int64, isDefault: bool] =
  ## Get information about currently loaded system image
  checkJlInitialized("getting system image info")

  let imagePath = $jl_get_default_sysimg_path()
  result.path = imagePath

  if fileExists(imagePath):
    result.size = getFileSize(imagePath)
  else:
    result.size = 0

  # Check if it's the default image (heuristic: in julia install dir)
  result.isDefault = imagePath.contains(JuliaPath)

when isMainModule:
  # Example usage
  echo "=== System Image Support Demo ==="

  # Example 1: Create a simple system image
  when false: # Set to true to actually run
    var config = defaultSysImageConfig()
    config.imagePath = "example_sys.so"
    config.packages = @["Statistics", "LinearAlgebra"]
    createSysImage(config)

  # Example 2: Use the convenient helper
  when false: # Set to true to actually run
    createAppSysImage("fast_app.so", packages = ["DataFrames", "CSV"], sourceFiles = ["app_init.jl"])
