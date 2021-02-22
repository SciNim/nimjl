import ../config

##Types
type julia_value *{.importc: "jl_value_t", header: juliaHeader.} = object
type julia_array *{.importc: "jl_array_t", header: juliaHeader.} = object
type julia_func *{.importc: "jl_function_t", header: juliaHeader.} = object
type julia_module *{.importc: "jl_module_t", header: juliaHeader.} = object

proc julia_eval_string*(code: cstring): ptr julia_value {.cdecl, importc.}

proc julia_eval_string*(code: string): ptr julia_value =
  result = julia_eval_string(code.cstring)

## Error handler
proc julia_exception_occurred*(): ptr julia_value {.cdecl, importc.}

proc julia_typeof_str*(v: ptr julia_value): cstring {.cdecl, importc.}

proc julia_string_ptr*(v: ptr julia_value): cstring {.cdecl, importc.}

