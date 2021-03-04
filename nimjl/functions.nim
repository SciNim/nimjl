import config
import basetypes
# import converttypes
import private/functions

proc getJlFunc*(funcname: string): JlFunc =
  result = jl_get_function(jlMainModule, funcname)

proc getJlFunc*(jlmod: JlModule, funcname: string): JlFunc =
  result = jl_get_function(jlmod, funcname)

proc jlCall*(jlfunc: JlFunc, va: varargs[JlValue]): JlValue =
  result = julia_exec_func(jlfunc, va)

proc jlCall*(jlfuncname: string, va: varargs[JlValue]): JlValue =
  result = julia_exec_func(jlMainModule, jlfuncname, va)

proc jlCall*(jlmod: JlModule, jlfuncname: string, va: varargs[JlValue]): JlValue =
  result = julia_exec_func(jlmod, jlfuncname, va)

