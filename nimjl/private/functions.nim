import basetypes
import ../config

## Call functions
proc julia_get_function*(module: ptr julia_module, name: cstring): ptr julia_func {.cdecl, importc.}

proc julia_call *(function: ptr julia_func, values: ptr ptr julia_value, nargs: cint): ptr julia_value {.cdecl, importc.}

proc julia_call0*(function: ptr julia_func): ptr julia_value {.cdecl, importc.}

proc julia_call1*(function: ptr julia_func, arg: ptr julia_value): ptr julia_value {.cdecl, importc.}

proc julia_call2*(function: ptr julia_func, arg1: ptr julia_value, arg2: ptr julia_value): ptr julia_value {.cdecl, importc.}

proc julia_call3*(function: ptr julia_func, arg1: ptr julia_value, arg2: ptr julia_value,
    arg3: ptr julia_value): ptr julia_value {.cdecl, importc.}

proc julia_exec_func*(module: ptr julia_module, func_name: string, va: varargs[ptr julia_value]): ptr julia_value =
  let f = julia_get_function(module, func_name)

  if va.len == 0:
    result = julia_call0(f)
  elif va.len == 1:
    result = julia_call1(f, va[0])
  elif va.len == 2:
    result = julia_call2(f, va[0], va[1])
  elif va.len == 3:
    result = julia_call3(f, va[0], va[1], va[2])
  else:
    result = julia_call(f, unsafeAddr(va[0]), va.len.cint)

proc julia_exec_func*(f: ptr julia_func, va: varargs[ptr julia_value]): ptr julia_value =
  if va.len == 0:
    result = julia_call0(f)
  elif va.len == 1:
    result = julia_call1(f, va[0])
  elif va.len == 2:
    result = julia_call2(f, va[0], va[1])
  elif va.len == 3:
    result = julia_call3(f, va[0], va[1], va[2])
  else:
    result = julia_call(f, unsafeAddr(va[0]), va.len.cint)


