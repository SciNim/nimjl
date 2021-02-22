import config
import basetypes

## Call functions
proc nimjl_get_function*(module: ptr nimjl_module, name: cstring): ptr nimjl_func {.cdecl, importc.}

proc nimjl_call *(function: ptr nimjl_func, values: ptr ptr nimjl_value, nargs: cint): ptr nimjl_value {.cdecl, importc.}

proc nimjl_call0*(function: ptr nimjl_func): ptr nimjl_value {.cdecl, importc.}

proc nimjl_call1*(function: ptr nimjl_func, arg: ptr nimjl_value): ptr nimjl_value {.cdecl, importc.}

proc nimjl_call2*(function: ptr nimjl_func, arg1: ptr nimjl_value, arg2: ptr nimjl_value): ptr nimjl_value {.cdecl, importc.}

proc nimjl_call3*(function: ptr nimjl_func, arg1: ptr nimjl_value, arg2: ptr nimjl_value, arg3: ptr nimjl_value): ptr nimjl_value {.cdecl, importc.}

proc nimjl_exec_func*(module: ptr nimjl_module, func_name: string, va: varargs[ptr nimjl_value]): ptr nimjl_value =
  let f = nimjl_get_function(module, func_name)

  if va.len == 0:
    result = nimjl_call0(f)
  elif va.len == 1:
    result = nimjl_call1(f, va[0])
  elif va.len == 2:
    result = nimjl_call2(f, va[0], va[1])
  elif va.len == 3:
    result = nimjl_call3(f, va[0], va[1], va[2])
  else:
    result = nimjl_call(f, unsafeAddr(va[0]), va.len.cint)

proc nimjl_exec_func*(func_name: string, va: varargs[ptr nimjl_value]): ptr nimjl_value =
  let f = nimjl_get_function(jl_main_module, func_name)

  if va.len == 0:
    result = nimjl_call0(f)
  elif va.len == 1:
    result = nimjl_call1(f, va[0])
  elif va.len == 2:
    result = nimjl_call2(f, va[0], va[1])
  elif va.len == 3:
    result = nimjl_call3(f, va[0], va[1], va[2])
  else:
    result = nimjl_call(f, unsafeAddr(va[0]), va.len.cint)


