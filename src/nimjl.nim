import os
# Const julia path
const C_NIMJL = "c/nimjl.c"
const JULIA_PATH = getEnv("JULIA_PATH") & "/"
const JULIA_INCLUDES_PATH = JULIA_PATH & "include/julia"
const JULIA_LIB_PATH = JULIA_PATH & "lib/"
const JULIA_DEPLIB_PATH = JULIA_PATH & "lib/julia"
#const JULIA_LIB = "libjulia.so"

const JULIA_INCLUDE_FLAG = "-I"&JULIA_INCLUDES_PATH
const JULIA_LINK_FLAG = ["-Wl,-rpath," & JULIA_LIB_PATH, "-Wl,-rpath," &
    JULIA_DEPLIB_PATH, "-lm", "-ljulia"]

{.compile: C_NIMJL, passc: JULIA_INCLUDE_FLAG, passL: JULIA_LINK_FLAG[0],
    passL: JULIA_LINK_FLAG[1], passL: JULIA_LINK_FLAG[2],
    passL: JULIA_LINK_FLAG[3].}
#{.link: JULIA_LIB_PATH & JULIA_LIB.}

##Types

type nimjl_value *{.importc: "jl_value_t*", header: "julia.h".} = pointer
type nimjl_array* = nimjl_value
type nimjl_datatype *{.importc: "jl_datatype_t", header: "julia.h".} = pointer
type nimjl_func *{.importc: "jl_function_t *", header: "julia.h".} = pointer
type nimjl_module *{.importc: "jl_module_t *", header: "julia.h".} = pointer

var jl_main_module *{.importc: "jl_main_module",
    header: "julia.h".}: nimjl_module
var jl_core_module *{.importc: "jl_core_module",
    header: "julia.h".}: nimjl_module
var jl_base_module *{.importc: "jl_base_module",
    header: "julia.h".}: nimjl_module
var jl_top_module *{.importc: "jl_top_module", header: "julia.h".}: nimjl_module

## Box & Unbox

proc nimjl_init*() {.importc.}
proc nimjl_eval_string*(code: cstring): nimjl_value {.importc.}

proc nimjl_atexit_hook*(exit_code: cint) {.importc.}

proc nimjl_unbox_float64*(value: nimjl_value): float64 {.importc.}
proc nimjl_unbox_float32*(value: nimjl_value): float32 {.importc.}

proc nimjl_unbox_int64*(value: nimjl_value): int64 {.importc.}
proc nimjl_unbox_int32*(value: nimjl_value): int32 {.importc.}
proc nimjl_unbox_int16*(value: nimjl_value): int16 {.importc.}
proc nimjl_unbox_int8*(value: nimjl_value): int8 {.importc.}

proc nimjl_unbox_uint64*(value: nimjl_value): uint64 {.importc.}
proc nimjl_unbox_uint32*(value: nimjl_value): uint32 {.importc.}
proc nimjl_unbox_uint16*(value: nimjl_value): uint16 {.importc.}
proc nimjl_unbox_uint8*(value: nimjl_value): uint8 {.importc.}

proc nimjl_box_float64*(value: float64): nimjl_value {.importc.}
proc nimjl_box_float32*(value: float32): nimjl_value {.importc.}

proc nimjl_box_int64*(value: int64): nimjl_value {.importc.}
proc nimjl_box_int32*(value: int32): nimjl_value {.importc.}
proc nimjl_box_int16*(value: int16): nimjl_value {.importc.}
proc nimjl_box_int8*(value: int8): nimjl_value {.importc.}

proc nimjl_box_uint64*(value: uint64): nimjl_value {.importc.}
proc nimjl_box_uint32*(value: uint32): nimjl_value {.importc.}
proc nimjl_box_uint16*(value: uint16): nimjl_value {.importc.}
proc nimjl_box_uint8*(value: uint8): nimjl_value {.importc.}


## Call functions
proc nimjl_get_function*(module: nimjl_module, name: cstring): nimjl_func {.importc.}

proc nimjl_call*(function: nimjl_func, values: pointer, nargs: cint): pointer {.importc.}

proc nimjl_call0*(function: nimjl_func): pointer {.importc.}

proc nimjl_call1*(function: nimjl_func, arg: pointer): pointer {.importc.}

proc nimjl_call2*(function: nimjl_func, arg1: pointer,
    arg2: pointer): pointer {.importc.}

proc nimjl_call3*(function: nimjl_func, arg1: pointer, arg2: pointer,
    arg3: pointer): pointer {.importc.}


## Array
# Values will need to be cast
proc nimjl_array_data*(values: nimjl_array): pointer {.importc.}

proc nimjl_array_dim*(a: nimjl_array, dim: cint): cint {.importc.}

proc nimjl_array_len*(a: nimjl_array): cint {.importc.}

proc nimjl_array_rank*(a: nimjl_array): cint {.importc.}

proc nimjl_new_array*(atype: nimjl_value, dims: nimjl_value): nimjl_array {.importc.}

proc nimjl_reshape_array*(atype: nimjl_value, data: nimjl_array,
    dims: nimjl_value): nimjl_array {.importc.}

proc nimjl_ptr_to_array_1d*(atype: nimjl_value, data: pointer, nel: csize_t,
    own_buffer: cint): nimjl_array {.importc.}

proc nimjl_ptr_to_array*(atype: nimjl_value, data: pointer, dims: nimjl_value,
    own_buffer: cint): nimjl_array {.importc.}

proc nimjl_alloc_array_1d*(atype: nimjl_value, nr: csize_t): nimjl_array {.importc.}

proc nimjl_alloc_array_2d*(atype: nimjl_value, nr: csize_t,
    nc: csize_t): nimjl_array {.importc.}

proc nimjl_alloc_array_3d*(atype: nimjl_value, nr: csize_t, nc: csize_t,
    z: csize_t): nimjl_array {.importc.}

##  Array type

proc nimjl_apply_array_type_int8*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_int16*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_int32*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_int64*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_uint8*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_uint16*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_uint32*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_uint64*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_float32*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_float64*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_bool*(dim: csize_t): nimjl_value {.importc.}

proc nimjl_apply_array_type_char*(dim: csize_t): nimjl_value {.importc.}

# proc nimjl_array_size(a: nimjl_array): csize_t {.importc.}

##GC Functions

proc nimjl_gc_push1*(a: pointer) {.importc.}

proc nimjl_gc_push2*(a: pointer, b: pointer) {.importc.}

proc nimjl_gc_push3*(a: pointer, b: pointer, c: pointer) {.importc.}

proc nimjl_gc_push4*(a: pointer, b: pointer, c: pointer, d: pointer) {.importc.}

proc nimjl_gc_push5*(a: pointer, b: pointer, c: pointer, d: pointer,
    e: pointer) {.importc.}

proc nimjl_gc_push6*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer,
    f: pointer) {.importc.}

proc nimjl_gc_pushargs*(a: ptr nimjl_value, n: csize_t) {.importc.}

proc nimjl_gc_pop*() {.importc.}

proc nimjl_exception_occurred*(): nimjl_value {.importc.}

proc nimjl_typeof_str*(v: nimjl_value): cstring {.importc.}
