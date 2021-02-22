import config
import private/basetypes

type
  JlValue* = ptr julia_value
  JlModule* = ptr julia_module
  JlFunc* = ptr julia_func

type JlArray*[T] = object
  data*: ptr julia_array
  types*: T

var jlMainModule *{.importc: "jl_main_module", header: juliaHeader.}: JlModule
var jlCoreModule *{.importc: "jl_core_module", header: juliaHeader.}: JlModule
var jlBaseModule *{.importc: "jl_base_module", header: juliaHeader.}: JlModule
var jlTopModule *{.importc: "jl_top_module", header: juliaHeader.}: JlModule


## Init & Exit function
proc jlVmInit*() {.cdecl, importc:"julia_init".}
proc jlVmExit*(exit_code: cint) {.cdecl, importc:"julia_atexit_hook".}

## Basic eval function
proc jlEval*(code: string): JlValue =
  result = julia_eval_string(code)


