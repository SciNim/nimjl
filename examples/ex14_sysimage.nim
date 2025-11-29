## Example demonstrating system image creation and usage
##
## This example shows how to create a custom Julia system image
## for faster startup and deployment without source code

import nimjl
import std/[os, strformat]

const SysImagePath = "example_sys.so"

proc createExampleSysImage() =
  ## Create a system image with common packages
  echo "=== Creating System Image ==="
  echo "This will take several minutes..."

  # Initialize Julia (needed to create system image)
  Julia.init()

  # Create example Julia files
  let initScript =
    """
# Custom initialization code
println("Loading custom system image...")

# Predefine functions to compile them
function greet(name)
    println("Hello, ", name, "!")
end

function fibonacci(n)
    if n <= 1
        return n
    end
    return fibonacci(n-1) + fibonacci(n-2)
end

println("Init loaded!")
"""

  let utilsScript =
    """
# Utility functions
function process_array(arr)
    return sum(arr .^ 2)
end

function mean_squared(arr)
    return sum(arr .^ 2) / length(arr)
end

println("Utils loaded!")
"""

  # Create a directory structure to demonstrate folder support
  createDir("julia_modules")
  writeFile("sys_init.jl", initScript)
  writeFile("julia_modules/utils.jl", utilsScript)

  try:
    # Create system image with common packages
    # Demonstrates both individual files and directories
    createAppSysImage(
      SysImagePath,
      packages = ["Statistics", "LinearAlgebra"],
      sourceFiles = ["sys_init.jl"], # Individual file
      sourceDirs = ["julia_modules/"], # Entire directory (all .jl files)
      optimize = 2,
    )

    echo "\n✓ System image created successfully!"
    echo &"  Path: {SysImagePath}"
    echo &"  Size: {getFileSize(SysImagePath) div (1024*1024)} MB"
    echo &"  Included files from: sys_init.jl, julia_modules/"
  finally:
    # Clean up
    if fileExists("sys_init.jl"):
      removeFile("sys_init.jl")
    if dirExists("julia_modules"):
      removeDir("julia_modules")

proc useExampleSysImage() =
  ## Use the created system image
  echo "\n=== Using System Image ==="

  if not fileExists(SysImagePath):
    echo "System image not found. Creating it first..."
    createExampleSysImage()
    echo ""

  # Initialize with custom system image
  let startTime = cpuTime()
  Julia.initWithSysImage(SysImagePath)
  let initTime = cpuTime() - startTime

  echo &"Julia initialized in {initTime:.3f} seconds"

  # Our custom functions are already loaded and compiled!
  echo "\nCalling precompiled functions:"

  # Call greet (from sys_init.jl)
  discard Julia.greet("World".toJlVal)

  # Call fibonacci (from sys_init.jl)
  let fib10 = Julia.fibonacci(jlBox(10)).to(int)
  echo &"fibonacci(10) = {fib10}"

  # Call process_array (from julia_modules/utils.jl)
  let data = @[1.0, 2.0, 3.0, 4.0, 5.0]
  let result = Julia.process_array(data.toJlVal).to(float)
  echo &"process_array([1,2,3,4,5]) = {result}"

  # Call mean_squared (from julia_modules/utils.jl)
  let ms = Julia.mean_squared(data.toJlVal).to(float)
  echo &"mean_squared([1,2,3,4,5]) = {ms}"

  # Use preloaded packages
  let arr = allocJlArray[float64]([10])
  for i in 0 ..< 10:
    arr.getRawData()[i] = float64(i)

  let mean = Julia.mean(cast[JlValue](arr)).to(float)
  echo &"mean of array = {mean}"

proc compareStartupTimes() =
  ## Compare startup time with and without system image
  echo "\n=== Startup Time Comparison ==="

  # Test with system image
  if fileExists(SysImagePath):
    let start1 = cpuTime()
    Julia.initWithSysImage(SysImagePath)
    let time1 = cpuTime() - start1
    Julia.exit()
    echo &"With system image: {time1:.3f}s"
  else:
    echo "System image not found, skipping comparison"
    echo "Run with 'create' option first"

proc showSysImageInfo() =
  ## Show information about current system image
  echo "\n=== System Image Information ==="

  if not jl_is_initialized().bool:
    Julia.init()

  let info = currentSysImageInfo()
  echo &"Current system image:"
  echo &"  Path: {info.path}"
  echo &"  Size: {info.size div (1024*1024)} MB"
  echo &"  Is default: {info.isDefault}"

proc main() =
  echo "=== Nimjl System Image Example ==="
  echo ""
  echo "Usage:"
  echo "  nim c -r ex14_sysimage.nim create  # Create system image"
  echo "  nim c -r ex14_sysimage.nim use     # Use system image"
  echo "  nim c -r ex14_sysimage.nim info    # Show image info"
  echo "  nim c -r ex14_sysimage.nim clean   # Remove image"
  echo ""

  if paramCount() == 0:
    echo "No command specified, showing all demos..."

    if not fileExists(SysImagePath):
      createExampleSysImage()

    useExampleSysImage()
    showSysImageInfo()
  else:
    let command = paramStr(1)
    case command
    of "create":
      createExampleSysImage()
    of "use":
      useExampleSysImage()
    of "info":
      showSysImageInfo()
    of "clean":
      if fileExists(SysImagePath):
        removeFile(SysImagePath)
        echo &"✓ Removed {SysImagePath}"
      else:
        echo "System image not found"
    else:
      echo &"Unknown command: {command}"

when isMainModule:
  main()
