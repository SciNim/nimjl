import ../config
import strutils
import strformat

{.used.}
##Types
type jl_value *{.importc: "jl_value_t", header: juliaHeader.} = object
type jl_array *{.importc: "jl_array_t", header: juliaHeader.} = object
type jl_func *{.importc: "jl_function_t", header: juliaHeader.} = object
type jl_module *{.importc: "jl_module_t", header: juliaHeader.} = object
type jl_datatype*{.importc: "jl_datatype_t", header: juliaHeader.} = object
type jl_sym*{.importc: "jl_sym_t", header: juliaHeader.} = object

{.push dynlib: juliaLibName}
proc jl_symbol*(symname: cstring): ptr jl_sym {.nodecl, importc: "jl_symbol".}

proc jl_eval_string*(code: cstring): ptr jl_value {.nodecl, importc.}

proc jl_eval_string*(code: string): ptr jl_value =
  result = jl_eval_string(code.cstring)

## Error handler
proc jl_exception_occurred*(): ptr jl_value {.nodecl, importc.}

proc jl_typeof_str*(v: ptr jl_value): cstring {.nodecl, importc.}

proc jl_string_ptr*(v: ptr jl_value): cstring {.nodecl, importc.}
{.pop.}
proc jl_exception_message*(): cstring =
  result = jl_string_ptr(jl_eval_string("sprint(showerror, ccall(:jl_exception_occurred, Any, ()))"))
  # result = jl_typeof_str(jl_exception_occurred())

proc jlvalue_to_string*(v: ptr jl_value): string =
  result = $(jl_string_ptr(v))

proc jlvalue_from_string*(v: string): ptr jl_value =
  # Replace any " in string by \"
  var tmp = replace(v, "\"", "\\\"")
  # Put the string into quote "
  tmp = &""""{tmp}""""
  result = jl_eval_string(tmp)

