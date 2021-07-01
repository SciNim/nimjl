import nimjl

Julia.init() # Initialize Julia VM. This should be done once in the lifetime of your program.

# Calling Julia function from Nim will always return a JlValue
# This JlValue can be "nothing"
# Therefore, Julia function who do not return a value can be discarded
var res = Julia.println("Hello world")
echo res # nothing
# Check that res is actually nothing
if res == JlNothing:
  echo "Julia.println returned nothing"

discard Julia.println("This also works")

Julia.exit() # Exit Julia VM. This can be done only once in the lifetime of your program.
