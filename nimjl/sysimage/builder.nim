## System image builder implementation
##
## Internal module for creating Julia system images

import ../types
import ../errors
import ../cores
import ../private/jlcores
import ../config
import std/[os, strformat, strutils, sequtils]

type SysImageConfig* = object
  ## Configuration for system image creation
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

proc expandJuliaFiles*(paths: openArray[string]): seq[string] =
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

proc validateSysImageConfig*(config: SysImageConfig) =
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

proc buildSysImage*(config: SysImageConfig) =
  ## Internal implementation for creating system images
  validateSysImageConfig(config)

  # Check if Julia is initialized (we need it to create the image)
  let wasInitialized = jlVmIsInit()
  if not wasInitialized:
    jl_init()
    jlInitialized = jl_is_initialized().bool  # Verify initialization succeeded

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
