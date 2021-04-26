import ../config
import std/strutils
import std/strformat

{.used.}
{.push header: JuliaHeader.}
# Types
type jl_value *{.importc: "jl_value_t", pure, final.} = object
type jl_array *{.importc: "jl_array_t", pure, final.} = object
type jl_func *{.importc: "jl_function_t", pure, final.} = object
type jl_module *{.importc: "jl_module_t", pure, final.} = object
type jl_datatype*{.importc: "jl_datatype_t", pure, final.} = object
type jl_sym*{.importc: "jl_sym_t", pure, final.} = object
{.pop.}

{.push nodecl, header: JuliaHeader, dynlib: JuliaLibName.}
proc jl_symbol*(symname: cstring): ptr jl_sym {.importc: "jl_symbol".}

proc jl_eval_string*(code: cstring): ptr jl_value {.importc: "jl_eval_string".}

# Error handler
proc jl_exception_occurred*(): ptr jl_value {.importc: "jl_exception_occurred".}

proc jl_typeof_str*(v: ptr jl_value): cstring {.importc: "jl_typeof_str".}

when defined(cpp):
  # CLANG fix for const char * vs char *
  proc jl_string_ptr*(v: ptr jl_value): cstring {.importcpp: "const_cast<char*>(jl_string_ptr(@))".}
else:
  proc jl_string_ptr*(v: ptr jl_value): cstring {.importc: "jl_string_ptr".}

proc jl_init*() {.importc: "jl_init".}
proc jl_atexit_hook*(exit_code: cint) {.importc: "jl_atexit_hook".}
{.pop.}

proc jl_eval_string*(code: string): ptr jl_value =
  result = jl_eval_string(code.cstring)

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

