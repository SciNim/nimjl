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
import ./private/jlbuilder
import ./config
import std/[os, strformat, macros, strutils]

# Re-export the config type for convenience
export jlbuilder.SysImageConfig, jlbuilder.defaultSysImageConfig

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
  jlbuilder.buildSysImage(config)

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

proc initWithSysImage*(imagePath: string, nthreads: int = 1) =
  ## Initialize Julia with a custom system image
  ## This is a convenience wrapper around jlVmInitWithImage
  jlVmInitWithImage(imagePath, nthreads)

proc createAppSysImage*(
    outputPath: string,
    packages: openArray[string],
    sourceFiles: openArray[string] = [],
    sourceDirs: openArray[string] = [],
    optimize: int = 2,
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

proc createAppSysImageWithEmbedded*(
    outputPath: string,
    packages: openArray[string],
    embeddedFiles: openArray[tuple[filename: string, content: string]] = [],
    optimize: int = 2
) =
  ## Create a system image with compile-time embedded Julia code
  ##
  ## Example:
  ## ```nim
  ## const code = staticRead("init.jl")
  ## createAppSysImageWithEmbedded(
  ##   "app.so",
  ##   packages = ["DataFrames"],
  ##   embeddedFiles = [("init.jl", code)]
  ## )
  ## ```

  var config = defaultSysImageConfig()
  config.imagePath = outputPath
  config.packages = @packages
  config.juliaCode = @embeddedFiles
  config.optimize = optimize

  createSysImage(config)

macro embedJuliaFile*(config: var SysImageConfig, filename: static[string]) =
  ## Embeds a Julia file's content into the SysImageConfig at compile-time
  let content = staticRead(filename)
  let baseFilename = filename.splitFile().name & filename.splitFile().ext
  quote do:
    `config`.juliaCode.add((`baseFilename`, `content`))

macro embedJuliaCode*(config: var SysImageConfig, name: static[string], code: static[string]) =
  ## Embed Julia code directly at compile-time
  quote do:
    `config`.juliaCode.add((`name`, `code`))

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
