import ../config
import basetypes_helpers
import strformat

var jl_bool_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_char_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_int8_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_uint8_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_int16_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_uint16_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_int32_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_uint32_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_int64_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_uint64_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_float32_type {.importc, header: juliaHeader.}: ptr jl_datatype
var jl_float64_type {.importc, header: juliaHeader.}: ptr jl_datatype


## Array bindings
# Values will need to be cast from jl_value to jl_array back and forth
{.push nodecl.}
proc jl_array_data*(values: ptr jl_array): pointer {.importc.}

proc jl_array_dim*(a: ptr jl_array, dim: cint): cint {.importc.}

proc jl_array_len*(a: ptr jl_array): cint {.importc.}

proc jl_array_rank*(a: ptr jl_array): cint {.importc.}

proc jl_new_array*(atype: ptr jl_value,
        dims: ptr jl_value): ptr jl_array {.importc.}

proc jl_reshape_array*(atype: ptr jl_value, data: ptr jl_array, dims: ptr jl_value): ptr jl_array {.
    importc.}

# Not wrapped -> Use generic version
# proc jl_ptr_to_array_1d*(atype: ptr jl_value, data: pointer, nel: csize_t,
#     own_buffer: cint): ptr jl_array {.importc.}

proc jl_ptr_to_array*(atype: ptr jl_value, data: pointer, dims: ptr jl_value,
    own_buffer: cint): ptr jl_array {.importc.}

proc jl_alloc_array_1d*(atype: ptr jl_value, nr: csize_t): ptr jl_array {.importc.}

proc jl_alloc_array_2d*(atype: ptr jl_value, nr: csize_t, nc: csize_t): ptr jl_array {.importc.}

proc jl_alloc_array_3d*(atype: ptr jl_value, nr: csize_t, nc: csize_t, z: csize_t): ptr jl_array {.importc.}

## Handle apply Array type mechanics
proc jl_apply_array_type(x: ptr jl_datatype, ndims: csize_t): ptr jl_value {.importc.}
{.pop.}

proc julia_apply_array_type*[T](dim: int): ptr jl_value =
  when T is int8:
    result = jl_apply_array_type(jl_int8_type, dim.csize_t)
  elif T is int16:
    result = jl_apply_array_type(jl_int16_type, dim.csize_t)
  elif T is int32:
    result = jl_apply_array_type(jl_int32_type, dim.csize_t)
  elif T is int64:
    result = jl_apply_array_type(jl_int64_type, dim.csize_t)
  elif T is uint8:
    result = jl_apply_array_type(jl_uint8_type, dim.csize_t)
  elif T is uint16:
    result = jl_apply_array_type(jl_uint16_type, dim.csize_t)
  elif T is uint32:
    result = jl_apply_array_type(jl_uint32_type, dim.csize_t)
  elif T is uint64:
    result = jl_apply_array_type(jl_uint64_type, dim.csize_t)
  elif T is float32:
    result = jl_apply_array_type(jl_float32_type, dim.csize_t)
  elif T is float64:
    result = jl_apply_array_type(jl_float64_type, dim.csize_t)
  elif T is bool:
    result = jl_apply_array_type(jl_bool_type, dim.csize_t)
  elif T is char:
    result = jl_apply_array_type(jl_char_type, dim.csize_t)
  else:
    doAssert(fals, "Type not supported")

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
    doAssert(false, &"Julia alloc array only supports Array for rank 1, 2, 3 not {dims.len}")

