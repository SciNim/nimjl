import ./types
import ./cores
import ./errors
import ./private/jlfuncs

import std/strformat

# Get a function
proc getJlFunc*(jlmod: JlModule, funcname: string): JlFunc =
  checkJlInitialized(&"getting function '{funcname}'")
  if jlmod.isNil:
    raise newException(JlNullPointerError, "Cannot get function from nil module")
  result = jl_get_function(jlmod, funcname)
  enhancedJlExceptionHandler(&"getting function '{funcname}'")
  if isNil(result):
    raise newException(JlError, &"Function '{funcname}' not found in module")

proc getJlFunc*(funcname: string): JlFunc =
  getJlFunc(JlMain, funcname)

# Add these 2 for convenience of the naming convention jl* of this package
proc jlGetFunc*(funcname: string): JlFunc =
  getJlFunc(funcname)

proc jlGetFunc*(jlmod: JlModule, funcname: string): JlFunc =
  getJlFunc(jlmod, funcname)

# Call function
proc jlCall*(jlfunc: JlFunc, va: varargs[JlValue, toJlVal]): JlValue =
  checkJlInitialized("calling Julia function")
  if jlfunc.isNil:
    raise newException(JlNullPointerError, "Cannot call nil function")
  result = julia_exec_func(jlfunc, va)
  enhancedJlExceptionHandler("calling Julia function")

proc jlCall*(jlmod: JlModule, jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  if jlmod.isNil:
    raise newException(JlNullPointerError, &"Cannot call function '{jlfuncname}' from nil module")
  let f = getJlFunc(jlmod, jlfuncname)
  result = jlCall(f, va)

proc jlCall*(jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  result = jlCall(JlMain, jlfuncname, va)
