import config
import basetypes

## Array bindings
# Values will need to be cast from nimjl_value to nimjl_array back and forth
proc nimjl_array_data*(values: ptr nimjl_array): pointer {.cdecl, importc.}

proc nimjl_array_dim*(a: ptr nimjl_array, dim: cint): cint {.cdecl, importc.}

proc nimjl_array_len*(a: ptr nimjl_array): cint {.cdecl, importc.}

proc nimjl_array_rank*(a: ptr nimjl_array): cint {.cdecl, importc.}

proc nimjl_new_array*(atype: ptr nimjl_value,
        dims: ptr nimjl_value): ptr nimjl_array {.cdecl, importc.}

proc nimjl_reshape_array*(atype: ptr nimjl_value, data: ptr nimjl_array,
    dims: ptr nimjl_value): ptr nimjl_array {.cdecl, importc.}

proc nimjl_ptr_to_array_1d*(atype: ptr nimjl_value, data: pointer, nel: csize_t,
    own_buffer: cint): ptr nimjl_array {.cdecl, importc.}

proc nimjl_ptr_to_array*(atype: ptr nimjl_value, data: pointer, dims: ptr nimjl_value,
    own_buffer: cint): ptr nimjl_array {.cdecl, importc.}

proc nimjl_alloc_array_1d*(atype: ptr nimjl_value,
        nr: csize_t): ptr nimjl_array {.cdecl, importc.}

proc nimjl_alloc_array_2d*(atype: ptr nimjl_value, nr: csize_t,
    nc: csize_t): ptr nimjl_array {.cdecl, importc.}

proc nimjl_alloc_array_3d*(atype: ptr nimjl_value, nr: csize_t, nc: csize_t,
    z: csize_t): ptr nimjl_array {.cdecl, importc.}

# Forward declaration for lisibility
proc nimjl_apply_array_type*[T](dim: int): ptr nimjl_value

proc nimjl_make_array*[T](data: ptr UncheckedArray[T], dims: openArray[int]): ptr nimjl_array =
  var dimStr = "("
  for d in dims:
    dimStr.add $d
    dimStr.add ","
  dimStr = dimStr & ")"
  var array_type: ptr nimjl_value = nimjl_apply_array_type[T](dims.len)
  result = nimjl_ptr_to_array(array_type, data, nimjl_eval_string(dimStr), 0.cint)

## Handle apply Array type mechanics
proc nimjl_apply_array_type_int8(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int16(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int32(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_int64(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint8(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint16(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint32(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_uint64(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_float32(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_float64(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_bool(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type_char(dim: csize_t): ptr nimjl_value {.cdecl, importc.}

proc nimjl_apply_array_type*[T](dim: int): ptr nimjl_value =
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
    doAssert(fals, "Type not supported")

