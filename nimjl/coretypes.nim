import ./config
import ./private/jlcores
import ./private/jlfuncs

type
  JlValue* = ptr jl_value
  JlModule* = ptr jl_module
  JlFunc* = ptr jl_func
  JlArray*[T] = ptr jl_array
  JlSym* = ptr jl_sym

type
  JlError* = object of IOError

{.push header: JuliaHeader.}
var
  JlMain*{.importc: "jl_main_module".}: JlModule
  JlCore*{.importc: "jl_core_module".}: JlModule
  JlBase*{.importc: "jl_base_module".}: JlModule
  JlTop*{.importc: "jl_top_module".}: JlModule

# TODO : Handle interrupt exception for SIGINT Throw ?
# Currently, you need to define setControlCHook AFTER jlVmInit() or it won't take effect
# var jl_interrupt_exception{.importc: "jl_interrupt_exception".}: JlValue
{.pop.}

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

proc jlStacktrace*() =
  let stacktrace_func = jl_get_function(JlMain, "stacktrace")
  let stacktrace = julia_exec_func(stacktrace_func)
  let println_func = jl_get_function(JlMain, "println")
  discard julia_exec_func(println_func, stacktrace)

proc jlExceptionHandler*() =
  let excpt : JlValue = jl_exception_occurred()
  if not isNil(excpt):
    let msg = $(jl_exception_message())
    jlStacktrace()
    raise newException(JlError, msg)
  else:
    discard

## Basic eval function
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)
  jlExceptionHandler()

proc nimStringToJlVal*(v: string): JlValue =
  result = jlvalue_from_string(v)

proc jlValToString*(v: JlValue): string =
  result = jlvalue_to_string(v)

proc jlSym*(symname: string): JlSym =
  result = jl_symbol(symname.cstring)
