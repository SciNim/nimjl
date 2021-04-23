import nimjl
import math

jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.
# Call Julia function "sqrt" and convert the result to a float
var res = jlCall("println", "Hello world")
jlVmExit() # Exit Julia VM. This can be done only once in the lifetime of your program.
