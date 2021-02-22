import config

##Types
type nimjl_value *{.importc: "jl_value_t", header: juliaHeader.} = object
type nimjl_array *{.importc: "jl_array_t", header: juliaHeader.} = object
type nimjl_func *{.importc: "jl_function_t", header: juliaHeader.} = object
type nimjl_module *{.importc: "jl_module_t", header: juliaHeader.} = object

var jl_main_module *{.importc: "jl_main_module", header: juliaHeader.}: ptr nimjl_module
var jl_core_module *{.importc: "jl_core_module", header: juliaHeader.}: ptr nimjl_module
var jl_base_module *{.importc: "jl_base_module", header: juliaHeader.}: ptr nimjl_module
var jl_top_module *{.importc: "jl_top_module", header: juliaHeader.}: ptr nimjl_module

## Init & Exit function
proc nimjl_init*() {.cdecl, importc.}
proc nimjl_atexit_hook*(exit_code: cint) {.cdecl, importc.}

## Basic eval function
proc nimjl_eval_string*(code: cstring): ptr nimjl_value {.cdecl, importc.}
proc nimjl_eval_string*(code: string): ptr nimjl_value =
  result = nimjl_eval_string(code.cstring)

## Error handler
proc nimjl_exception_occurred*(): ptr nimjl_value {.cdecl, importc.}

proc nimjl_typeof_str*(v: ptr nimjl_value): cstring {.cdecl, importc.}

proc nimjl_string_ptr*(v: ptr nimjl_value): cstring {.cdecl, importc.}

