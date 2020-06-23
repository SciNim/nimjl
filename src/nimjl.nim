const C_NIMJL = "c/nimjl.c"
const JULIA_PATH = "~/julia-1.4.2/"
const JULIA_INCLUDES_PATH = JULIA_PATH & "include/julia"
const JULIA_LIB_PATH = JULIA_PATH & "lib/"
const JULIA_LIB = "libjulia.so"
const JULIA_DEPLIB_PATH = JULIA_PATH & "lib/julia"

const JULIA_INCLUDE_FLAG = "-I"&JULIA_INCLUDES_PATH
const JULIA_LINK_FLAG = ["-Wl,-rpath," & JULIA_LIB_PATH, "-Wl,-rpath," & JULIA_DEPLIB_PATH,"-lm", "-ljulia"]

{.compile: C_NIMJL, passc:JULIA_INCLUDE_FLAG, passL:JULIA_LINK_FLAG[0], passL:JULIA_LINK_FLAG[1], passL:JULIA_LINK_FLAG[2], passL:JULIA_LINK_FLAG[3].}
# {.link: JULIA_LIB_PATH & JULIA_LIB.}

type nimjl_value *{.importc: "jl_value_t*", header: "julia.h".} = distinct pointer
type nimjl_array *{.importc: "jl_array_t", header: "julia.h".} = object
type nimjl_func  *{.importc: "jl_function_t *", header: "julia.h".} = distinct pointer
type nimjl_module*{.importc: "jl_module_t *", header: "julia.h".} = distinct pointer

proc nimjl_init*() {.importc.}
proc nimjl_eval_string*(code: cstring) : nimjl_value {.importc.}

proc nimjl_atexit_hook*(exit_code : cint) {.importc.}

proc nimjl_unbox_float64*(value: nimjl_value) : float64 {.importc.}
proc nimjl_unbox_float32*(value: nimjl_value) : float32 {.importc.}

proc nimjl_unbox_int64*(value: nimjl_value)   : int64   {.importc.}
proc nimjl_unbox_int32*(value: nimjl_value)   : int32   {.importc.}
proc nimjl_unbox_int16*(value: nimjl_value)   : int16   {.importc.}
proc nimjl_unbox_int8* (value: nimjl_value)   : int8    {.importc.}

proc nimjl_unbox_uint64*(value: nimjl_value)  : uint64  {.importc.}
proc nimjl_unbox_uint32*(value: nimjl_value)  : uint32  {.importc.}
proc nimjl_unbox_uint16*(value: nimjl_value)  : uint16  {.importc.}
proc nimjl_unbox_uint8* (value: nimjl_value)  : uint8   {.importc.}

proc nimjl_box_float64* (value: float64)  : nimjl_value  {.importc.}
proc nimjl_box_float32* (value: float32)  : nimjl_value  {.importc.}

proc nimjl_box_int64*   (value: int64)    : nimjl_value  {.importc.}
proc nimjl_box_int32*   (value: int32)    : nimjl_value  {.importc.}
proc nimjl_box_int16*   (value: int16)    : nimjl_value  {.importc.}
proc nimjl_box_int8*    (value: int8)     : nimjl_value  {.importc.}

proc nimjl_box_uint64*  (value: uint64)   : nimjl_value  {.importc.}
proc nimjl_box_uint32*  (value: uint32)   : nimjl_value  {.importc.}
proc nimjl_box_uint16*  (value: uint16)   : nimjl_value  {.importc.}
proc nimjl_box_uint8*   (value: uint8)    : nimjl_value  {.importc.}

proc nimjl_get_function*(name: cstring): nimjl_func {.importc.}
proc nimjl_call*(function: nimjl_func, values: ptr nimjl_value, nargs: cint): nimjl_value {.importc.}

# Values will need to be cast
# is it possible to
proc nimjl_array_data(values: nimjl_array): ptr {.importc:"jl_array_data", header: "julia.h".}

