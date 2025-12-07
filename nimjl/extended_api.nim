## Extended Julia API bindings
##
## This module provides additional Julia C API functions that are commonly needed
## Note: This module is currently under development and not yet integrated into the main nimjl module

import ./private/jlcores
import ./config
import ./types
import ./errors
import std/strformat

# These bindings extend the core Julia C API with additional commonly-used functions
# They are kept separate to avoid conflicts with existing bindings

{.push nodecl, header: JuliaHeader, dynlib: JuliaLibName.}

# Additional module operations not in core
proc jl_module_name(m: JlModule): JlSym {.importc: "jl_module_name".}
proc jl_module_parent(m: JlModule): JlModule {.importc: "jl_module_parent".}
proc jl_symbol_name(sym: JlSym): cstring {.importc: "jl_symbol_name".}

# Additional type checking functions
proc jl_is_nothing(val: JlValue): cint {.importc: "jl_is_nothing".}
proc jl_is_tuple(val: JlValue): cint {.importc: "jl_is_tuple".}
proc jl_is_array(val: JlValue): cint {.importc: "jl_is_array".}
proc jl_is_string(val: JlValue): cint {.importc: "jl_is_string".}

# String operations
proc jl_string_len(s: JlValue): csize_t {.importc: "jl_string_len".}

# Tuple/struct operations
proc jl_nfields(val: JlValue): cint {.importc: "jl_nfields".}

# Additional GC control
proc jl_gc_safepoint() {.importc: "jl_gc_safepoint".}

# Threading info
proc jl_n_threads(): cint {.importc: "jl_n_threads".}
proc jl_threadid(): cint {.importc: "jl_threadid".}

# System image functions
proc jl_get_default_sysimg_path(): cstring {.importc: "jl_get_default_sysimg_path".}
proc jl_get_libdir(): cstring {.importc: "jl_get_libdir".}

{.pop.}

# High-level wrapper functions with Nim-friendly types

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

proc jlGetNThreads*(): int =
  ## Get number of Julia threads
  checkJlInitialized("getting thread count")
  result = jl_n_threads().int

proc jlGetThreadId*(): int =
  ## Get current Julia thread ID (0-indexed)
  checkJlInitialized("getting thread ID")
  result = jl_threadid().int

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
