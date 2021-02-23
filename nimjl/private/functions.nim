import basetypes_helpers
import ../config

## Call functions
{.push nodecl.}
proc jl_get_function*(module: ptr jl_module, name: cstring): ptr jl_func {.importc:"jl_get_function".}

proc jl_call *(function: ptr jl_func, values: ptr ptr jl_value, nargs: cint): ptr jl_value {.importc:"jl_call".}

proc jl_call0*(function: ptr jl_func): ptr jl_value {.nodecl, importc:"jl_call0".}

proc jl_call1*(function: ptr jl_func, arg: ptr jl_value): ptr jl_value {.importc:"jl_call1".}

proc jl_call2*(function: ptr jl_func, arg1: ptr jl_value, arg2: ptr jl_value): ptr jl_value {.importc:"jl_call2".}

proc jl_call3*(function: ptr jl_func, arg1: ptr jl_value, arg2: ptr jl_value,
    arg3: ptr jl_value): ptr jl_value {.importc:"jl_call3".}

{.pop.}

proc julia_exec_func*(module: ptr jl_module, func_name: string, va: varargs[ptr jl_value]): ptr jl_value =
  let f = jl_get_function(module, func_name)

  if va.len == 0:
    result = jl_call0(f)
  elif va.len == 1:
    result = jl_call1(f, va[0])
  elif va.len == 2:
    result = jl_call2(f, va[0], va[1])
  elif va.len == 3:
    result = jl_call3(f, va[0], va[1], va[2])
  else:
    result = jl_call(f, unsafeAddr(va[0]), va.len.cint)

proc julia_exec_func*(f: ptr jl_func, va: varargs[ptr jl_value]): ptr jl_value =
  if va.len == 0:
    result = jl_call0(f)
  elif va.len == 1:
    result = jl_call1(f, va[0])
  elif va.len == 2:
    result = jl_call2(f, va[0], va[1])
  elif va.len == 3:
    result = jl_call3(f, va[0], va[1], va[2])
  else:
    result = jl_call(f, unsafeAddr(va[0]), va.len.cint)

