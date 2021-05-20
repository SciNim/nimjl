import ./private/jlcores
import ./private/jlfuncs
import ./types

import std/strformat

# Init & Exit function
proc jlVmInit*() =
  ## jlVmInit should only be called once per process
  ## Subsequent calls after the first one will be ignored
  once:
    jl_init()
    return
  raise newException(JlError, "jl_init() must be called once per process")

proc jlVmExit*(exit_code: cint = 0.cint) =
  ## jlVmExit should only be called once per process
  ## Subsequent calls after the first one will be ignored
  once:
    jl_atexit_hook(exit_code)
    return
  raise newException(JlError, "jl_atexit_hook() must be called once per process")

# Julia Error handling
proc jlStacktrace*() =
  let println= jl_get_function(JlMain, "println")
  let backtrace= jl_get_function(JlMain, "backtrace")

  let trace = julia_exec_func(backtrace)

  discard julia_exec_func(println, trace)
  let lookup= jl_get_function(JlMain, "lookup")

proc jlExceptionHandler*() =
  let excpt : JlValue = jl_exception_occurred()
  if not isNil(excpt):
    let msg = $(jl_exception_message())
    jlStacktrace()
    raise newException(JlError, msg)
  else:
    discard

# Eval function
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)
  jlExceptionHandler()

# String conversion
proc nimStringToJlVal*(v: string): JlValue =
  result = jlvalue_from_string(v)
proc jlValToString*(v: JlValue): string =
  result = jlvalue_to_string(v)

# Convert a string to Julia Symbol
proc jlSym*(symname: string): JlSym =
  result = jl_symbol(symname.cstring)

# Include file or use module
# Check for nil result
proc jlInclude*(filename: string) =
  let tmp = jlEval(&"include(\"{file_name}\")")
  assert not tmp.isNil()

proc jlUseModule*(modname: string) =
  let tmp = jlEval(&"using {modname}")
  assert not tmp.isNil()

proc jlGetModule*(modname: string): JlModule =
  result = cast[JlModule](jlEval(modname))
