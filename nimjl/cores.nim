import ./types
import ./private/jlcores

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

# Convert a string to Julia Symbol
proc jlSym*(symname: string): JlSym =
  result = jl_symbol(symname.cstring)

proc jlExceptionHandler*() =
  let excpt: JlValue = jl_exception_occurred()
  if not isNil(excpt):
    let msg = $(jl_exception_message())
    raise newException(JlError, msg)
  else:
    discard

# Eval function that checkes error
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)
  jlExceptionHandler()

# Include file or use module
# Check for nil result
proc jlInclude*(filename: string) =
  let tmp = jlEval(&"include(\"{filename}\")")
  if tmp.isNil:
    raise newException(JlError, "&Cannot include file {filename}")

proc jlUseModule*(modname: string) =
  let tmp = jlEval(&"using {modname}")
  if tmp.isNil:
    raise newException(JlError, "&Cannot use module {modname}")

# Just for convenience since Julia funciton is called using
proc jlUsing*(modname: string) =
  jlUseModule(modname)

# Import can be useful
proc jlImport*(modname: string) =
  let tmp = jlEval(&"import {modname}")
  if tmp.isNil:
    raise newException(JlError, "&Cannot import module {modname}")

proc jlGetModule*(modname: string): JlModule =
  let tmp = jlEval(modname)
  if tmp.isNil:
    raise newException(JlError, "&Cannot load module {modname}")
  result = cast[JlModule](tmp)

# JlNothing is handy to have
template JlNothing*(): JlValue = jlEval("nothing")
