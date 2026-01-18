## Example demonstrating system image API
##
## This example shows the system image API without actually
## creating images (which takes minutes and requires PackageCompiler)

import nimjl
import nimjl/sysimage
import std/[os, strformat]

proc demonstrateAPI() =
  echo "=== System Image API Demo ==="
  echo ""
  
  # Show how to configure a system image
  echo "1. Creating system image configuration:"
  var config = defaultSysImageConfig()
  config.imagePath = "example.so"
  config.packages = @["Statistics", "LinearAlgebra"]
  config.optimize = 2
  
  echo &"  Image path: {config.imagePath}"
  echo &"  Packages: {config.packages}"
  echo &"  Optimization level: {config.optimize}"
  echo ""
  
  # Show the convenient helper
  echo "2. Using convenient helper (createAppSysImage):"
  echo "  createAppSysImage("
  echo "    \"myapp.so\","
  echo "    packages = [\"DataFrames\", \"Plots\"],"
  echo "    sourceFiles = [\"init.jl\"],"
  echo "    sourceDirs = [\"src/\"]"
  echo "  )"
  echo ""
  
  # Show how to query system image info
  echo "3. System image information:"
  Julia.init()
  let info = currentSysImageInfo()
  echo &"  Current image path: {info.path}"
  echo &"  Size: {info.size div (1024*1024)} MB"
  echo &"  Is default Julia image: {info.isDefault}"
  echo ""
  
  echo "Note: To actually create and use custom system images,"
  echo "uncomment the creation code in this file and run with"
  echo "sufficient time (several minutes required)."

proc demonstrateCreation() =
  ## Demonstrates actual system image creation (disabled by default)
  echo "\n=== System Image Creation (Example Code) ==="
  echo ""
  echo "To create a system image, you would:"
  echo ""
  echo "  Julia.init()"
  echo "  createAppSysImage("
  echo "    \"fast_app.so\","
  echo "    packages = [\"Statistics\"],"
  echo "    sourceFiles = [\"my_functions.jl\"],"
  echo "    optimize = 2"
  echo "  )"
  echo ""
  echo "Then initialize Julia with:"
  echo "  initWithSysImage(\"fast_app.so\")"

proc main() =
  echo "=== Nimjl System Image Example ==="
  echo "This demonstrates the system image API"
  echo ""
  
  demonstrateAPI()
  demonstrateCreation()
  
  echo "\n✓ Example complete"

when isMainModule:
  main()
