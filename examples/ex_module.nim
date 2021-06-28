import nimjl

type MyTuple = tuple[nimTupKey1: int, nimTupKey2: int]

Julia.init() # Initialize Julia VM. This should be done once in the lifetime of your program.

# Include Julia file
jlInclude("ex_module.jl")
# Use the module. If you're confused by the syntax, go and read through Julia's Manual where module usage is explained
jlUseModule(".nimjlExample")

# Look, you can pass Nim tuple to Julia
var mytup: MyTuple = (nimTupKey1: 1, nimTupKey2: 2)
var res = Julia.customFunction(mytup)
var nimres = res.to(MyTuple)

echo myTup
echo nimres

doAssert myTup.nimTupKey1+1 == nimres.nimTupKey1
doAssert myTup.nimTupKey2+1 == nimres.nimTupKey2

var foo = Julia.makeFoo()
# You can access fields with dot syntax
echo foo.x
echo foo.y
echo foo.z

# You can modify objects
foo.x = 2
foo.y = 3.14
foo.z = "General Kenobi !"

echo foo

Julia.exit() # Exit Julia VM. This can be done only once in the lifetime of your program.
