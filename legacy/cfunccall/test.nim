import src/jlwrapper

nimjl_init()

block:
  var res: ptr jl_value = nil
  res = nimjl_include_file("test.jl")
  doAssert not isNil(res)
  res = nimjl_using_module(".custom_module")
  doAssert not isNil(res)

block:
  callAddMeBabyInt()

block:
  var fPtr: pointer
  fPtr = get_nimfunction_pointer("julia_addMeBabyInt")
  # proc julia_addMeBabyInt(a: cint, b: cint): cint {.cdecl.} = cast[(proc(a: cint, b: cint): cint  {.cdecl.})](fPtr)
  var julia_addMeBabyInt: (proc(a: cint, b: cint): cint {.cdecl.}) = cast[(proc(a: cint, b: cint): cint {.cdecl.})](fPtr)
  echo ">>>", julia_addMeBabyInt(3.cint, 4.cint)

block:
  var fPtr = get_nimfunction_pointer("julia_dummy")
  if not isNil(fPtr):
    var julia_dummy: (proc() {.gcsafe, cdecl.}) = cast[(proc() {.gcsafe, cdecl.})](fPtr)
    julia_dummy()
  else:
    echo "Error fPtr isNil"

block:
  var valPtr = nimjl_eval_string("@cfunction(custom_module.dummy, Cvoid, ())")
  var fPtr : pointer

  if not valPtr.isNil:
    fPtr = nimjl_unbox_voidpointer(valPtr)
  else:
    echo "Error valPtr isNil"

  if not isNil(fPtr):
    var julia_dummy: (proc() {.gcsafe, cdecl.}) = cast[(proc() {.gcsafe, cdecl.})](fPtr)
    julia_dummy()
  else:
    echo "Error fPtr isNil"

nimjl_atexit_hook(0)

