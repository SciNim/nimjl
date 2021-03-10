import config
import basetypes
import private/functions

import strformat

proc getJlFunc*(funcname: string): JlFunc =
  result = jl_get_function(jlMainModule, funcname)
  jlExceptionHandler()
  if isNil(result):
    raise newException(JlError, &"Function {funcname} does not exists.")

proc getJlFunc*(jlmod: JlModule, funcname: string): JlFunc =
  result = jl_get_function(jlmod, funcname)
  jlExceptionHandler()
  if isNil(result):
    raise newException(JlError, &"Function {funcname} does not exists.")

proc jlCall*(jlfunc: JlFunc, va: varargs[JlValue, toJlVal]): JlValue =
  result = julia_exec_func(jlfunc, va)
  jlExceptionHandler()

proc jlCall*(jlmod: JlModule, jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  let f = getJlFunc(jlmod, jlfuncname)
  result = jlCall(f, va)

proc jlCall*(jlfuncname: string, va: varargs[JlValue, toJlVal]): JlValue =
  result = jlCall(jlMainModule, jlfuncname, va)

