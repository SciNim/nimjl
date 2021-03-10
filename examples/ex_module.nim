import nimjl

type MyTuple = tuple[nimTupKey1: int, nimTupKey2: int]

jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.

# Include Julia file
jlInclude("ex_module.jl")
# Use the module. If you're confused by the syntax, go and read through Julia's Manual where module usage is explained
jlUseModule(".nimjlExample")

# Look, you can pass Nim tuple to Julia
var mytup: MyTuple = (nimTupKey1: 1, nimTupKey2: 2)
var res = jlCall("customFunction", mytup)
var nimres = res.to(MyTuple)

echo myTup
echo nimres

doAssert myTup.nimTupKey1+1 == nimres.nimTupKey1
doAssert myTup.nimTupKey2+1 == nimres.nimTupKey2

jlVmExit() # Exit Julia VM. This can be done only once in the lifetime of your program.
