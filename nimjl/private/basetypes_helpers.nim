import ../config

{.used.}
##Types
type jl_value *{.importc: "jl_value_t", header: juliaHeader.} = object
type jl_array *{.importc: "jl_array_t", header: juliaHeader.} = object
type jl_func *{.importc: "jl_function_t", header: juliaHeader.} = object
type jl_module *{.importc: "jl_module_t", header: juliaHeader.} = object
type jl_datatype*{.importc: "jl_datatype_t", header: juliaHeader.} = object

proc jl_eval_string*(code: cstring): ptr jl_value {.nodecl, importc.}

proc jl_eval_string*(code: string): ptr jl_value =
  result = jl_eval_string(code.cstring)

## Error handler
proc jl_exception_occurred*(): ptr jl_value {.importc.}

proc jl_typeof_str*(v: ptr jl_value): cstring {.importc.}

proc jl_string_ptr*(v: ptr jl_value): cstring {.importc.}

