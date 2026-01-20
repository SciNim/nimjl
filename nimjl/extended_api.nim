## Extended Julia API - High-level wrappers
##
## This module provides high-level Nim-friendly wrappers for additional Julia C API functions
## Note: This module is currently under development and not yet integrated into the main nimjl module

import ./private/jlcores
import ./private/jlextapi
import ./config
import ./types
import ./errors
import ./cores
import ./functions
import ./conversions/tojl
import ./conversions/fromjl

# High-level wrapper functions with Nim-friendly types and error handling

proc jlGetModuleName*(m: JlModule): string =
  ## Get name of module
  checkJlInitialized("getting module name")
  let sym = jl_module_name(m)
  result = $jl_symbol_name(sym)
  enhancedJlExceptionHandler("getting module name")

proc jlGetModuleParent*(m: JlModule): JlModule =
  ## Get parent module
  checkJlInitialized("getting parent module")
  result = jl_module_parent(m)
  enhancedJlExceptionHandler("getting parent module")

proc jlCheckNothing*(val: JlValue): bool =
  ## Check if value is nothing
  if val.isNil:
    return true
  result = jl_is_nothing(val) != 0

proc jlCheckTuple*(val: JlValue): bool =
  ## Check if value is a tuple
  if val.isNil:
    return false
  result = jl_is_tuple(val) != 0

proc jlCheckArray*(val: JlValue): bool =
  ## Check if value is an array
  if val.isNil:
    return false
  result = jl_is_array(val) != 0

proc jlCheckString*(val: JlValue): bool =
  ## Check if value is a string
  if val.isNil:
    return false
  result = jl_is_string(val) != 0

proc jlGcSafepoint*() =
  ## Insert a GC safepoint for cooperative garbage collection
  jl_gc_safepoint()

# Threading API
proc jlGetNThreads*(): int =
  ## Get number of Julia threads by calling Threads.nthreads()
  checkJlInitialized("getting thread count")
  let threadsModule = jlGetModule("Threads")
  let nthreadsFunc = jlGetFunc(threadsModule, "nthreads")
  result = jlCall(nthreadsFunc).to(int)

proc jlGetThreadId*(): int =
  ## Get current Julia thread ID by calling Threads.threadid()
  checkJlInitialized("getting thread ID")
  let threadsModule = jlGetModule("Threads")
  let threadidFunc = jlGetFunc(threadsModule, "threadid")
  result = jlCall(threadidFunc).to(int)

proc jlGetStringLen*(s: JlValue): int =
  ## Get length of Julia string
  checkJlInitialized("getting string length")
  result = jl_string_len(s).int
  enhancedJlExceptionHandler("getting string length")

proc jlGetNFields*(val: JlValue): int =
  ## Get number of fields in tuple/struct
  checkJlInitialized("getting tuple length")
  result = jl_nfields(val).int
  enhancedJlExceptionHandler("getting tuple length")

proc jlGetSysImagePath*(): string =
  ## Get path to current system image
  checkJlInitialized("getting system image path")
  result = $jl_get_default_sysimg_path()

proc jlGetLibDir*(): string =
  ## Get Julia library directory
  checkJlInitialized("getting library directory")
  result = $jl_get_libdir()
