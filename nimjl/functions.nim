import ./types
import ./cores
import ./private/jlfuncs

import std/strformat

# Get a function
proc getJlFunc*(jlmod: JlModule, funcname: string): JlFunc =
  result = jl_get_function(jlmod, funcname)
  jlExceptionHandler()
  if isNil(result):
    raise newException(JlError, &"Function {funcname} does not exists.")

proc getJlFunc*(funcname: string): JlFunc =
  getJlFunc(JlMain, funcname)

# Add these 2 for convenience of the naming convention jl* of this package
proc jlGetFunc*(funcname: string): JlFunc =
  getJlFunc(funcname)

proc jlGetFunc*(jlmod: JlModule, funcname: string): JlFunc =
  getJlFunc(jlmod, funcname)

# Call function
proc jlCall*(jlfunc: JlFunc, va: varargs[JlValue, toJlVal]): JlValue =
  result = julia_exec_func(jlfunc, va)
  jlExceptionHandler()

proc jlCall*(jlmod: JlModule, jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  let f = getJlFunc(jlmod, jlfuncname)
  result = jlCall(f, va)

proc jlCall*(jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  result = jlCall(JlMain, jlfuncname, va)

