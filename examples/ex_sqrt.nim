import nimjl
import math

jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.

var myval = 4.0'f64
# Call Julia function "sqrt" and convert the result to a float
# This syntax also works to call a function directly from a Julia modfule
var res = JlBase.sqrt(myval).to(float64)
# Echo on JlValue calls println from Julia
echo res # 2.0
doAssert res == sqrt(myval)

