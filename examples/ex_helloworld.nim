import nimjl
import math

Julia.init() # Initialize Julia VM. This should be done once in the lifetime of your program.
# Call Julia function "sqrt" and convert the result to a float
var res = Julia.println("Hello world")
Julia.exit() # Exit Julia VM. This can be done only once in the lifetime of your program.
