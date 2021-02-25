import config
import private/basetypes_helpers
import json
import strformat

type
  JlValue* = ptr jl_value
  JlModule* = ptr jl_module
  JlFunc* = ptr jl_func

  JlArray*[T] = object
    data*: ptr jl_array


type
  JlError* = object of IOError

var jlMainModule *{.importc: "jl_main_module", header: juliaHeader.}: JlModule
var jlCoreModule *{.importc: "jl_core_module", header: juliaHeader.}: JlModule
var jlBaseModule *{.importc: "jl_base_module", header: juliaHeader.}: JlModule
var jlTopModule *{.importc: "jl_top_module", header: juliaHeader.}: JlModule


## Init & Exit function
proc jlVmInit*() {.nodecl, importc: "jl_init".}
proc jlVmExit*(exit_code: cint) {.nodecl, importc: "jl_atexit_hook".}

proc jlString*(v: JlValue) : string =
  result = $(jl_string_ptr(v))

proc jlExceptionHandler*() =
  if not isNil(jl_exception_occurred()):
    let msg = $(jl_exception_message())
    raise newException(JlError, msg)
  else:
    discard

## Basic eval function
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)
  jlExceptionHandler()

proc toJlString*(v: string) : JlValue=
  let tmp = "\"" & v & "\""
  result = jlEval(tmp)

# TODO fix this
proc jlDict*(json: JsonNode) : JlValue =
  let json = $(json)
  echo json
  result = jlEval(&"JSON.parse({json})")
