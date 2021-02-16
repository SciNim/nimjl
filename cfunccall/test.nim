import src/jlwrapper

nimjl_init()

block:
  var res: ptr jl_value = nil
  res = nimjl_include_file("test.jl")
  doAssert not isNil(res)
  res = nimjl_using_module(".custom_module")
  doAssert not isNil(res)

block:
  var fPtr = get_cfunction_pointer("julia_addMeBabyInt")
  echo fPtr.repr
  var julia_addMeBabyInt: (proc(a: cint, b: cint): cint) = cast[ptr (proc(a: cint, b: cint): cint)](fPtr)[]
  echo julia_addMeBabyInt(3.cint, 4.cint)
  echo fPtr.repr

block:
  # var fPtr = get_cfunction_pointer("julia_dummy")
  # echo fPtr.repr
  var valPtr = nimjl_eval_string("@cfunction(custom_module.dummy, Cvoid, (Cvoid,))")
  if not isNil(valPtr):
    var fPtr = nimjl_unbox_voidpointer(valPtr)
    echo fPtr.repr
    var julia_dummy: (proc(): void) = cast[ptr proc(): void](fPtr)[]
    julia_dummy()
    echo fPtr.repr

nimjl_atexit_hook(0)
