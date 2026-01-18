## Example demonstrating compile-time embedded Julia code in system images
##
## This shows the API for embedding Julia code at compile-time

import nimjl
import nimjl/sysimage
import std/[os, strformat]

# Example of embedded Julia code
const EmbeddedJuliaCode = """
# Custom Julia functions defined at compile-time
module NimEmbedded

export greet, calculate

function greet(name::String)
    return "Hello from embedded Julia, " * name * "!"
end

function calculate(x::Number, y::Number)
    return x^2 + y^2
end

end  # module
"""

proc demonstrateEmbeddedAPI() =
  echo "=== Compile-Time Embedded Code Demo ==="
  echo ""
  
  echo "1. Julia code embedded at compile-time:"
  echo "  const EmbeddedJuliaCode = \"\"\"...Julia code...\"\"\""
  echo ""
  
  echo "2. The embedded code can be used:"
  echo "  a) During normal Julia.init with jlEmbedFile/jlEmbedDir"
  echo "  b) In system images using SysImageConfig"
  echo ""
  
  echo "3. Example system image config with embedded code:"
  echo "  var config = defaultSysImageConfig()"
  echo "  config.imagePath = \"embedded.so\""
  echo "  config.packages = @[\"Statistics\"]"
  echo "  config.includeEmbedded = true  # Include compile-time files"
  echo ""
  
  echo "4. The embedded code is:"
  echo "----------------------------------------"
  echo EmbeddedJuliaCode
  echo "----------------------------------------"
  echo ""

proc demonstrateUsage() =
  echo "5. Using embedded functions at runtime:"
  echo ""
  
  # We can actually test the embedded code works with regular init
  Julia.init()
  
  # Evaluate the embedded module
  discard jlEval(EmbeddedJuliaCode)
  discard jlEval("using .NimEmbedded")
  
  # Test the embedded functions
  let greeting = Julia.greet("Nim User".toJlVal).to(string)
  echo &"  {greeting}"
  
  let result = Julia.calculate(jlBox(3.0), jlBox(4.0)).to(float)
  echo &"  calculate(3, 4) = {result}"
  echo ""
  
  echo "Note: With a system image, these functions would be"
  echo "precompiled for instant availability at startup."

proc main() =
  echo "=== Nimjl Embedded System Image Example ==="
  echo ""
  
  demonstrateEmbeddedAPI()
  demonstrateUsage()
  
  echo "\n✓ Example complete"

when isMainModule:
  main()
