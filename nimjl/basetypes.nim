import config
import private/basetypes_helpers
import json
import tables
import strutils
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

proc jlDict*(json: JsonNode) : JlValue =
  var dictStr = "Dict(["
  for k, v in json:
    dictStr.add &"(\"{k}\",{v}),"
  dictStr = dictStr.strip(chars = {','})
  dictStr.add "])"
  result = jlEval(dictStr)

proc jlDict*[T](tab: Table[string, T]) : JlValue =
  let json = %tab
  var dictStr = "Dict(["
  for k, v in json:
    dictStr.add &"(\"{k}\",{v}),"
  dictStr = dictStr.strip(chars = {','})
  dictStr.add "])"
  result = jlEval(dictStr)

