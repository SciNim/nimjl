##  Helper function to retrieve pointers to cfunctions on the Julia side.
import os
import arraymancer
import strutils
import strformat

# Const julia path
const csrc_jl = "csrc/jl.c"
const juliaPath = getEnv("JULIA_PATH")
const juliaIncludesPath = juliaPath / "include" / "julia"
const juliaLibPath = juliaPath / "lib"
const juliaDepPath = juliaPath / "lib" / "julia"
const juliaHeader = "julia.h"

{.passC: "-fPIC".}
{.passC: " -DJULIA_ENABLE_THREADING=1".}
{.passC: "-I" & juliaIncludesPath.}
{.passL: "-L" & juliaLibPath.}
{.passL: "-Wl,-rpath," & juliaLibPath.}
{.passL: "-L" & juliaDepPath.}
{.passL: "-Wl,-rpath," & juliaDepPath.}
{.passL: "-ljulia".}
{.compile: csrc_jl.}

static:
  echo "juliaPath> ", juliaPath
  echo "juliaIncludesPath> ", juliaIncludesPath
  echo "juliaLibPath> ", juliaLibPath
# {.push header: juliaHeader.}

##Types
type jl_value *{.importc: "jl_value_t", header: juliaHeader.} = object
type jl_array *{.importc: "jl_array_t", header: juliaHeader.} = object
type jl_func *{.importc: "jl_function_t", header: juliaHeader.} = object
type jl_sym *{.importc: "jl_sym_t", header: juliaHeader.} = object
type jl_module *{.importc: "jl_module_t", header: juliaHeader.} = object

var jl_main_module *{.importc: "jl_main_module", header: juliaHeader.}: ptr jl_module
var jl_core_module *{.importc: "jl_core_module", header: juliaHeader.}: ptr jl_module
var jl_base_module *{.importc: "jl_base_module", header: juliaHeader.}: ptr jl_module
var jl_top_module *{.importc: "jl_top_module", header: juliaHeader.}: ptr jl_module

## Basic function
proc nimjl_init*() {.cdecl, importc.}
proc nimjl_gc_enable*(toggle: cint) {.cdecl, importc.}
proc nimjl_atexit_hook*(exit_code: cint) {.cdecl, importc.}
proc nimjl_eval_string*(code: cstring): ptr jl_value {.cdecl, importc.}

proc nimjl_eval_string*(code: string): ptr jl_value =
  result = nimjl_eval_string(code.cstring)

proc nimjl_get_global*(module: ptr jl_module, name: cstring): ptr jl_value {.cdecl, importc.}

proc nimjl_unbox_voidpointer(p: pointer): pointer {.cdecl, importc.}

# proc nimjl_get_global*(module: ptr nimjl_module, sym: ptr jl_sym): ptr jl_sym{.cdecl, importc.}
# proc nimjl_symbol(name: cstring) : ptr jl_sym {.cdecl, importc.}

proc get_cfunction_pointer*(name: cstring): pointer =
  var p: pointer = nil
  # var boxed_pointer: ptr jl_value_t = nimjl_get_global(jl_main_module, nimjl_symbol(name))
  var boxed_pointer: ptr jl_value = nimjl_get_global(jl_main_module, name)
  if not isNil(boxed_pointer): p = nimjl_unbox_voidpointer(boxed_pointer)
  if isNil(p): stderr.write(&"cfunction pointer {name} not available.\n")
  return p


