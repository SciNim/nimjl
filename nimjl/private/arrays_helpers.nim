import ../config
import basetypes_helpers
import strformat

{.push header: juliaHeader.}

let
  jl_bool_type {.importc.}: ptr jl_datatype
  jl_char_type {.importc.}: ptr jl_datatype
  jl_int8_type {.importc.}: ptr jl_datatype
  jl_uint8_type {.importc.}: ptr jl_datatype
  jl_int16_type {.importc.}: ptr jl_datatype
  jl_uint16_type {.importc.}: ptr jl_datatype
  jl_int32_type {.importc.}: ptr jl_datatype
  jl_uint32_type {.importc.}: ptr jl_datatype
  jl_int64_type {.importc.}: ptr jl_datatype
  jl_uint64_type {.importc.}: ptr jl_datatype
  jl_float32_type {.importc.}: ptr jl_datatype
  jl_float64_type {.importc.}: ptr jl_datatype
{.pop.}
## Array bindings
{.push nodecl.}
proc jl_array_data*(values: ptr jl_array): pointer {.importc.}
proc jl_array_dim*(a: ptr jl_array, dim: cint): cint {.importc.}
proc jl_array_len*(a: ptr jl_array): cint {.importc.}
proc jl_array_rank*(a: ptr jl_value): cint {.importc.}
proc jl_new_array*(atype: ptr jl_value, dims: ptr jl_value): ptr jl_array {.importc.}
proc jl_reshape_array*(atype: ptr jl_value, data: ptr jl_array, dims: ptr jl_value): ptr jl_array {.importc.}

proc jl_ptr_to_array*(atype: ptr jl_value, data: pointer, dims: ptr jl_value, own_buffer: cint): ptr jl_array {.importc.}

proc jl_alloc_array_1d*(atype: ptr jl_value, nr: csize_t): ptr jl_array {.importc.}
proc jl_alloc_array_2d*(atype: ptr jl_value, nr: csize_t, nc: csize_t): ptr jl_array {.importc.}
proc jl_alloc_array_3d*(atype: ptr jl_value, nr: csize_t, nc: csize_t, z: csize_t): ptr jl_array {.importc.}

## Handle apply Array type mechanics
proc jl_apply_array_type(x: ptr jl_value, ndims: csize_t): ptr jl_value {.importc.}
{.pop.}

proc julia_type(T: typedesc[int8]): ptr jl_datatype {.inline.} = jl_int8_type
proc julia_type(T: typedesc[int16]): ptr jl_datatype {.inline.} = jl_int16_type
proc julia_type(T: typedesc[int32]): ptr jl_datatype {.inline.} = jl_int32_type
proc julia_type(T: typedesc[int64]): ptr jl_datatype {.inline.} = jl_int64_type

proc julia_type(T: typedesc[int]): ptr jl_datatype {.inline.} =
  when sizeof(T) == sizeof(int64):
    julia_type(int64)
  elif sizeof(T) == sizeof(int32):
    julia_type(int32)

proc julia_type(T: typedesc[uint8]): ptr jl_datatype {.inline.} = jl_uint8_type
proc julia_type(T: typedesc[uint16]): ptr jl_datatype {.inline.} = jl_uint16_type
proc julia_type(T: typedesc[uint32]): ptr jl_datatype {.inline.} = jl_uint32_type
proc julia_type(T: typedesc[uint64]): ptr jl_datatype {.inline.} = jl_uint64_type

proc julia_type(T: typedesc[uint]): ptr jl_datatype {.inline.} =
  when sizeof(T) == sizeof(uint64):
    julia_type(uint64)
  elif sizeof(T) == sizeof(uint32):
    julia_type(uint32)

proc julia_type(T: typedesc[bool]): ptr jl_datatype {.inline.} = jl_bool_type
proc julia_type(T: typedesc[char]): ptr jl_datatype {.inline.} = jl_char_type
proc julia_type(T: typedesc[float32]): ptr jl_datatype {.inline.} = jl_float32_type
proc julia_type(T: typedesc[float64]): ptr jl_datatype {.inline.} = jl_float64_type

proc julia_apply_array_type*[T: SomeNumber|bool|char](dim: int): ptr jl_value =
  let jl_type = cast[ptr jl_value](julia_type(T))
  jl_apply_array_type(jl_type, dim.csize_t)

proc julia_make_array*[T](data: ptr UncheckedArray[T], dims: openArray[int]): ptr jl_array =
  var dimStr = "("
  for d in dims:
    dimStr.add $d
    dimStr.add ","
  dimStr = dimStr & ")"
  var array_type = julia_apply_array_type[T](dims.len)
  result = jl_ptr_to_array(array_type, data, jl_eval_string(dimStr), 0.cint)

proc julia_alloc_array*[T](dims: openArray[int]): ptr jl_array =
  case dims.len
  of 1:
    var array_type = julia_apply_array_type[T](1)
    result = jl_alloc_array_1d(array_type, dims[0].csize_t)
  of 2:
    var array_type = julia_apply_array_type[T](2)
    result = jl_alloc_array_2d(array_type, dims[0].csize_t, dims[1].csize_t)
  of 3:
    var array_type = julia_apply_array_type[T](3)
    result = jl_alloc_array_3d(array_type, dims[0].csize_t, dims[1].csize_t, dims[2].csize_t)
  else:
    raise newException(JlError, &"Julia alloc array only supports Array for rank 1, 2, 3 not {dims.len}")

