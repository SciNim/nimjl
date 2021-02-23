import config
import private/basetypes_helpers

type
  JlValue* = ptr jl_value
  JlModule* = ptr jl_module
  JlFunc* = ptr jl_func

  JlArray*[T] = object
    data*: ptr jl_array

var jlMainModule *{.importc: "jl_main_module", header: juliaHeader.}: JlModule
var jlCoreModule *{.importc: "jl_core_module", header: juliaHeader.}: JlModule
var jlBaseModule *{.importc: "jl_base_module", header: juliaHeader.}: JlModule
var jlTopModule *{.importc: "jl_top_module", header: juliaHeader.}: JlModule


## Init & Exit function
proc jlVmInit*() {.nodecl, importc: "jl_init".}
proc jlVmExit*(exit_code: cint) {.nodecl, importc: "jl_atexit_hook".}

## Basic eval function
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)

