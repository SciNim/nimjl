##  Helper function to retrieve pointers to cfunctions on the Julia side.
import os
import strformat

# Const julia path
const csrc_jl = "csrc/jl.c"
# const csrc_jl = "csrc/cfunctions.c"
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
# proc nimjl_gc_enable*(toggle: cint) {.cdecl, importc.}
proc nimjl_atexit_hook*(exit_code: cint) {.cdecl, importc.}
proc nimjl_eval_string*(code: cstring): ptr jl_value {.cdecl, importc.}

proc nimjl_eval_string*(code: string): ptr jl_value =
  result = nimjl_eval_string(code.cstring)

proc nimjl_include_file*(file_name: string): ptr jl_value =
  result = nimjl_eval_string(&"include(\"{file_name}\")")

proc nimjl_using_module*(module_name: string): ptr jl_value =
  result = nimjl_eval_string(&"using {module_name}")

# Make function pointers
proc nimjl_get_global*(module: ptr jl_module, name: cstring): ptr jl_value {.cdecl, importc.}
proc nimjl_unbox_voidpointer*(p: pointer): pointer {.cdecl, importc.}
# proc nimjl_get_global*(module: ptr jl_module, sym: ptr jl_sym): ptr jl_sym{.cdecl, importc.}
# proc nimjl_symbol(name: cstring) : ptr jl_sym {.cdecl, importc.}

proc get_cfunction_pointer*(name: cstring): pointer {.cdecl, importc.}
proc callAddMeBabyInt*() {.cdecl, importc.}

proc get_nimfunction_pointer*(name: cstring): pointer =
  var p: pointer = nil
  var boxed_pointer: ptr jl_value = nimjl_get_global(jl_main_module, name)
  if not isNil(boxed_pointer): p = nimjl_unbox_voidpointer(boxed_pointer)
  if isNil(p): stderr.write(&"cfunction pointer {name} not available.\n")
  return p

## Array type
proc nimjl_apply_array_type_int8(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int16(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int32(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int64(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint8(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint16(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint32(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint64(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_float32(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_float64(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_bool(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type_char(dim: csize_t): ptr jl_value {.cdecl, importc.}

proc nimjl_apply_array_type*[T](dim: int): ptr jl_value =
  when T is int8:
    result = nimjl_apply_array_type_int8(dim.csize_t)
  elif T is int16:
    result = nimjl_apply_array_type_int16(dim.csize_t)
  elif T is int32:
    result = nimjl_apply_array_type_int32(dim.csize_t)
  elif T is int64:
    result = nimjl_apply_array_type_int64(dim.csize_t)
  elif T is uint8:
    result = nimjl_apply_array_type_uint8(dim.csize_t)
  elif T is uint16:
    result = nimjl_apply_array_type_uint16(dim.csize_t)
  elif T is uint32:
    result = nimjl_apply_array_type_uint32(dim.csize_t)
  elif T is uint64:
    result = nimjl_apply_array_type_uint64(dim.csize_t)
  elif T is float32:
    result = nimjl_apply_array_type_float32(dim.csize_t)
  elif T is float64:
    result = nimjl_apply_array_type_float64(dim.csize_t)
  elif T is bool:
    result = nimjl_apply_array_type_bool(dim.csize_t)
  elif T is char:
    result = nimjl_apply_array_type_char(dim.csize_t)
  else:
    doAssert(false, "Type not supported")

## Array Utils
# Values will need to be cast from nimjl_value to nimjl_array back and forth
proc nimjl_array_data*(values: ptr jl_array): pointer {.cdecl, importc.}

proc nimjl_array_dim*(a: ptr jl_array, dim: cint): cint {.cdecl, importc.}

proc nimjl_array_len*(a: ptr jl_array): cint {.cdecl, importc.}

proc nimjl_array_rank*(a: ptr jl_array): cint {.cdecl, importc.}

proc nimjl_new_array*(atype: ptr jl_value, dims: ptr jl_value): ptr jl_array {.cdecl, importc.}

proc nimjl_reshape_array*(atype: ptr jl_value, data: ptr jl_array,
    dims: ptr jl_value): ptr jl_array {.cdecl, importc.}

proc nimjl_ptr_to_array*(atype: ptr jl_value, data: pointer, dims: ptr jl_value,
    own_buffer: cint): ptr jl_array {.cdecl, importc.}

proc nimjl_make_array*[T](data: ptr UncheckedArray[T], dims: openArray[int]): ptr jl_array =
  var array_type: ptr jl_value = nimjl_apply_array_type[T](dims.len)
  var dimStr = "("
  for d in dims:
    dimStr.add $d
    dimStr.add ","
  dimStr = dimStr & ")"
  var xDims = nimjl_eval_string(dimStr)
  result = nimjl_ptr_to_array(array_type, data, xDims, 0)

