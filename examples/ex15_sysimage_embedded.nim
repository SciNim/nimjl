## Example demonstrating system image creation with compile-time embedded Julia code
##
## This shows how to embed Julia code at compile-time into a system image,
## avoiding the need to distribute .jl files separately.
##
## Uses the existing jlEmbedFile/jlEmbedDir infrastructure from nimjl

import nimjl
import std/os

const SysImagePath = "embedded_sys.so"

# Embed Julia files at compile-time using existing nimjl macros
# These will be automatically included in the system image
jlEmbedFile("julia_embedded_code.jl")

# Create a Julia file to embed
const EmbeddedJuliaCode = """
# Custom Julia functions defined at compile-time in Nim
module NimEmbedded

export greet, calculate, process_data

function greet(name::String)
    println("Hello from embedded Julia, ", name, "!")
    return "Greeted: " * name
end

function calculate(x::Number, y::Number)
    return x^2 + y^2
end

function process_data(arr::Vector)
    return sum(arr .^ 2) / length(arr)
end

end  # module

# Make functions available at top level
using .NimEmbedded
"""

# Write the embedded code to a temp file so we can embed it
static:
  writeFile("julia_embedded_code.jl", EmbeddedJuliaCode)

proc createEmbeddedSysImage() =
  ## Create system image with embedded Julia code (no external .jl files!)
  echo "=== Creating System Image with Embedded Code ==="
  echo "All Julia code is embedded at compile-time in the Nim binary"
  echo "Using the existing jlEmbedFile infrastructure"
  echo ""

  Julia.init()

  # The embedded files are automatically included!
  # Just create the system image with includeEmbedded = true (default)
  var config = defaultSysImageConfig()
  config.imagePath = SysImagePath
  config.packages = @["Statistics"]
  config.includeEmbedded = true  # Include compile-time embedded files
  config.optimize = 2

  createSysImage(config)

  echo "\n✓ System image created with embedded code!"
  echo &"  No external .jl files needed for distribution"

proc createEmbeddedSysImageAdvanced() =
  ## Advanced: Mix embedded and runtime files
  echo "=== Creating System Image with Mixed Approach ==="

  Julia.init()

  var config = defaultSysImageConfig()
  config.imagePath = SysImagePath
  config.packages = @["Statistics", "LinearAlgebra"]
  config.includeEmbedded = true  # Include compile-time embedded files
  config.optimize = 3

  # You can also add runtime files if needed
  # config.juliaFiles = @["runtime_extras.jl"]

  createSysImage(config)

  echo "\n✓ System image created!"

proc useEmbeddedSysImage() =
  ## Use the created system image with embedded code
  echo "\n=== Using System Image with Embedded Code ==="

  if not fileExists(SysImagePath):
    echo "System image not found. Creating it first..."
    createEmbeddedSysImage()
    echo ""

  # Initialize with custom system image
  Julia.initWithSysImage(SysImagePath)

  echo "Testing embedded functions:"

  # Call the embedded greeting function
  let greeting = Julia.greet("Nim User".toJlVal).to(string)
  echo &"  {greeting}"

  # Call the embedded calculate function
  let result = Julia.calculate(jlBox(3.0), jlBox(4.0)).to(float)
  echo &"  calculate(3, 4) = {result}"

  # Call the embedded process_data function
  let data = @[1.0, 2.0, 3.0, 4.0, 5.0]
  let processed = Julia.process_data(data.toJlVal).to(float)
  echo &"  process_data([1,2,3,4,5]) = {processed}"

  # Use preloaded Statistics package
  let mean = Julia.mean(data.toJlVal).to(float)
  echo &"  mean([1,2,3,4,5]) = {mean}"

proc demonstrateAdvantages() =
  ## Show advantages of compile-time embedding
  echo "\n=== Advantages of Compile-time Embedding ==="
  echo ""
  echo "✓ Single binary distribution"
  echo "  - No need to ship .jl files separately"
  echo "  - Easier deployment"
  echo ""
  echo "✓ Compile-time validation"
  echo "  - Files checked at Nim compile time"
  echo "  - Catch missing files early"
  echo ""
  echo "✓ Code protection"
  echo "  - Julia source not visible in deployed binary"
  echo "  - Precompiled to native code"
  echo ""
  echo "✓ Consistency"
  echo "  - Julia code version locked with Nim binary"
  echo "  - No runtime file loading issues"

proc compareApproaches() =
  ## Compare different approaches to system image creation
  echo "\n=== System Image Creation Approaches ==="
  echo ""

  echo "1. Runtime files only:"
  echo "   var config = defaultSysImageConfig()"
  echo "   config.juliaFiles = [\"init.jl\"]  # Files must exist at runtime"
  echo "   config.includeEmbedded = false"
  echo "   createSysImage(config)"
  echo ""

  echo "2. Compile-time embedded (using jlEmbedFile):"
  echo "   jlEmbedFile(\"init.jl\")  # At top level, compile-time"
  echo "   var config = defaultSysImageConfig()"
  echo "   config.includeEmbedded = true  # Include embedded files"
  echo "   createSysImage(config)"
  echo ""

  echo "3. Mixed approach:"
  echo "   jlEmbedFile(\"core.jl\")  # Core logic embedded"
  echo "   var config = defaultSysImageConfig()"
  echo "   config.juliaFiles = [\"config.jl\"]  # Config at runtime"
  echo "   config.includeEmbedded = true"
  echo "   createSysImage(config)"

proc main() =
  echo "=== Nimjl System Image with Compile-time Embedded Code ==="
  echo ""

  if paramCount() == 0:
    demonstrateAdvantages()
    compareApproaches()
    echo ""
    echo "Usage:"
    echo "  nim c -r ex15_sysimage_embedded.nim create   # Create image"
    echo "  nim c -r ex15_sysimage_embedded.nim use      # Use image"
    echo "  nim c -r ex15_sysimage_embedded.nim clean    # Remove image"
    return

  let command = paramStr(1)
  case command
  of "create":
    createEmbeddedSysImage()
  of "create-advanced":
    createEmbeddedSysImageAdvanced()
  of "use":
    useEmbeddedSysImage()
  of "demo":
    demonstrateAdvantages()
    compareApproaches()
  of "clean":
    if fileExists(SysImagePath):
      removeFile(SysImagePath)
      echo &"✓ Removed {SysImagePath}"
    else:
      echo "System image not found"
  else:
    echo &"Unknown command: {command}"
    echo "Valid commands: create, create-advanced, use, demo, clean"

when isMainModule:
  main()
