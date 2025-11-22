## Enhanced error handling for nimjl
##
## This module provides better error messages and initialization checking

import ./types
import ./private/jlcores
import std/[strformat, strutils]

type
  JlInitError* = object of JlError
    ## Raised when Julia VM is not initialized
  JlMemoryError* = object of JlError
    ## Raised when memory operations fail
  JlNullPointerError* = object of JlError
    ## Raised when encountering unexpected null pointers

proc checkJlInitialized*(operation: string = "") =
  ## Check if Julia VM is initialized, raise detailed error if not
  if not jl_is_initialized().bool:
    var msg = "Julia VM is not initialized."
    if operation.len > 0:
      msg.add &" Cannot perform operation: {operation}"
    msg.add "\n  Solution: Call Julia.init() before using Julia functions."
    msg.add "\n  Example:"
    msg.add "\n    import nimjl"
    msg.add "\n    Julia.init()"
    msg.add "\n    # Now you can call Julia functions"
    raise newException(JlInitError, msg)

proc checkNotNil*[T](val: ptr T, context: string = ""): ptr T =
  ## Check if pointer is not nil, raise detailed error if it is
  if val.isNil:
    var msg = &"Unexpected null pointer"
    if context.len > 0:
      msg.add &" in context: {context}"
    msg.add "\n  This may indicate:"
    msg.add "\n    - Julia function returned nil/nothing"
    msg.add "\n    - Invalid type conversion"
    msg.add "\n    - Memory corruption"
    msg.add "\n    - Julia exception that wasn't caught"
    raise newException(JlNullPointerError, msg)
  return val

proc enhancedJlExceptionHandler*(context: string = "") =
  ## Enhanced exception handler with better error messages
  let excpt: JlValue = jl_exception_occurred()
  if not isNil(excpt):
    var msg = ""

    # Try to get detailed error message
    try:
      let errorMsg = jl_exception_message()
      msg = $errorMsg
    except:
      # Fallback if exception message extraction fails
      msg = "Julia exception occurred (could not extract message)"

    # Add context if provided
    if context.len > 0:
      msg = &"Julia error in {context}:\n  {msg}"

    # Try to get stack trace in debug mode
    when not defined(release):
      try:
        let stacktraceVal = jl_eval_string(
          "sprint(showerror, ccall(:jl_exception_occurred, Any, ()), catch_backtrace())"
        )
        if not stacktraceVal.isNil:
          let stacktrace = jl_string_ptr(stacktraceVal)
          msg.add "\n\nJulia Stack Trace:\n"
          msg.add $stacktrace
      except:
        # Silently ignore stack trace extraction failures
        discard

    raise newException(JlError, msg)

proc checkJlMemory*(size: int, operation: string = "") =
  ## Check if memory allocation would be reasonable
  const MaxReasonableSize = 1024 * 1024 * 1024 * 10  # 10 GB

  if size < 0:
    raise newException(JlMemoryError,
      &"Invalid negative size: {size} for operation: {operation}")

  if size > MaxReasonableSize:
    raise newException(JlMemoryError,
      &"Suspiciously large memory allocation: {size} bytes ({size div (1024*1024*1024)} GB) for operation: {operation}\n" &
      "  This may indicate a bug. If intentional, increase MaxReasonableSize.")

# Removed withJlErrorContext template - use checkJlInitialized and enhancedJlExceptionHandler directly

proc jlDiagnostic*(): string =
  ## Get diagnostic information about Julia state
  result = "Julia VM Diagnostic Information:\n"
  result.add &"  Initialized: {jl_is_initialized().bool}\n"

  if jl_is_initialized().bool:
    try:
      result.add &"  Julia Version: {$jl_eval_string(\"string(VERSION)\").jl_string_ptr()}\n"
      result.add &"  System Image: {$jl_get_default_sysimg_path()}\n"
      result.add &"  Library Dir: {$jl_get_libdir()}\n"

      # Get thread info
      let nthreads = jl_eval_string("Threads.nthreads()")
      if not nthreads.isNil:
        result.add &"  Threads: {$jl_string_ptr(jl_eval_string(\"string(Threads.nthreads())\"))}\n"

      # Get memory info
      let meminfo = jl_eval_string("Base.gc_live_bytes()")
      if not meminfo.isNil:
        result.add &"  Live Memory: {$jl_string_ptr(jl_eval_string(\"string(round(Base.gc_live_bytes() / 1024^2, digits=2))\"))} MB\n"
    except:
      result.add "  (Could not get additional info - Julia may be in unstable state)\n"
  else:
    result.add "  Call Julia.init() to initialize\n"

proc getJlTypeInfo*(val: JlValue): string =
  ## Get detailed type information for debugging
  if val.isNil:
    return "nil (null pointer)"

  try:
    let typename = jl_typeof_str(val)
    result = $typename

    # Try to get more info for arrays
    if result.find("Array") >= 0:
      let sizeinfo = jl_eval_string(&"string(size(ccall(:jl_value_ptr, Any, (Ptr{{Cvoid}},), {cast[uint](val)})))")
      if not sizeinfo.isNil:
        result.add &" size: {$jl_string_ptr(sizeinfo)}"
  except:
    result = "unknown (error getting type info)"
