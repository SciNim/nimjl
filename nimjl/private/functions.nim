import basetypes_helpers
import ../config

## Call functions
{.push nodecl.}
proc jl_get_function*(module: ptr jl_module, name: cstring): ptr jl_func {.importc: "jl_get_function".}

proc jl_call *(function: ptr jl_func, values: ptr ptr jl_value, nargs: cint): ptr jl_value {.importc: "jl_call".}

proc jl_call0*(function: ptr jl_func): ptr jl_value {.importc: "jl_call0".}

{.pop.}

proc julia_exec_func*(f: ptr jl_func, va: varargs[ptr jl_value]): ptr jl_value =
  if va.len == 0:
    result = jl_call0(f)
  else:
    result = jl_call(f, unsafeAddr(va[0]), va.len.cint)

