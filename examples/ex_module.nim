import nimjl

type
  MyTuple = tuple[nimTupKey1: int, nimTupKey2: int] # Used to convert to a Julia tuple
  Foo = object # This is mapped as object <-> struct therefore fields must correspond
    x: int
    y: float
    z: string

Julia.init() # Initialize Julia VM. This should be done once in the lifetime of your program.

# Include Julia file
jlInclude("ex_module.jl")
# Use the module. If you're confused by the syntax, go and read through Julia's Manual where module usage is explained
jlUseModule(".nimjlExample")

block: # Tuple handling
  # Look, you can pass Nim tuple to Julia
  var mytup: MyTuple = (nimTupKey1: 1, nimTupKey2: 2)
  # Convert Nim tuple to Julia tuple automatically
  var res = Julia.customFunction(mytup)
  # Convert Julia tuple to Nim tuple
  var nimres = res.to(MyTuple)

  echo myTup
  echo nimres

  doAssert myTup.nimTupKey1+1 == nimres.nimTupKey1
  doAssert myTup.nimTupKey2+1 == nimres.nimTupKey2

block: # Object manipulation
  # Call constructor
  var foo = Julia.makeFoo()
  # Access fields with dot syntax
  # Calls getproperty in Julia side
  echo foo.x
  echo foo.y
  echo foo.z
  # Modify fields with .= syntax
  # Calls setproperty! on Julia side
  foo.x = 2
  foo.y = 3.14
  foo.z = "General Kenobi !"
  # Yay this has been modified
  echo foo

  # You can use dot syntax on Julia value to call proc as well
  discard foo.applyToFoo()
  echo foo

block:
  var foo = Foo(x: 12, y: 15, z: "This string comes from Nim")
  # You can convert Nim to Julia object if :
  # * fields have the same name and type (fieldName becomdes Julia symbol)
  # * The Julia type have an empty constructor -- Nim needs to initialize the Julia variable before calling setproperty! providing a default empty constructor is the easiest way of doing it
  var jlfoo = toJlVal(foo)
  echo jlfoo
  echo jltypeof(jlfoo) # This echo "Foo" -> Julia sees this as a Foo mutable struct type

  discard jlfoo.applyToFoo()
  # Object are copid during conversions so modifying jlfoo does not modify foo
  # There is an exception to this for Array fields -- see ex_arrays for explanation
  echo jlfoo
  echo foo

Julia.exit() # Exit Julia VM. This can be done only once in the lifetime of your program.
