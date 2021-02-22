import ../config
import basetypes

## Array bindings
# Values will need to be cast from julia_value to julia_array back and forth
proc julia_array_data*(values: ptr julia_array): pointer {.cdecl, importc.}

proc julia_array_dim*(a: ptr julia_array, dim: cint): cint {.cdecl, importc.}

proc julia_array_len*(a: ptr julia_array): cint {.cdecl, importc.}

proc julia_array_rank*(a: ptr julia_array): cint {.cdecl, importc.}

proc julia_new_array*(atype: ptr julia_value,
        dims: ptr julia_value): ptr julia_array {.cdecl, importc.}

proc julia_reshape_array*(atype: ptr julia_value, data: ptr julia_array, dims: ptr julia_value): ptr julia_array {.cdecl, importc.}

# Not wrapped -> Use generic version
# proc julia_ptr_to_array_1d*(atype: ptr julia_value, data: pointer, nel: csize_t,
#     own_buffer: cint): ptr julia_array {.cdecl, importc.}

proc julia_ptr_to_array*(atype: ptr julia_value, data: pointer, dims: ptr julia_value,
    own_buffer: cint): ptr julia_array {.cdecl, importc.}

proc julia_alloc_array_1d*(atype: ptr julia_value,
        nr: csize_t): ptr julia_array {.cdecl, importc.}

proc julia_alloc_array_2d*(atype: ptr julia_value, nr: csize_t,
    nc: csize_t): ptr julia_array {.cdecl, importc.}

proc julia_alloc_array_3d*(atype: ptr julia_value, nr: csize_t, nc: csize_t,
    z: csize_t): ptr julia_array {.cdecl, importc.}

## Handle apply Array type mechanics
proc julia_apply_array_type_int8(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_int16(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_int32(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_int64(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_uint8(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_uint16(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_uint32(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_uint64(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_float32(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_float64(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_bool(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type_char(dim: csize_t): ptr julia_value {.cdecl, importc.}

proc julia_apply_array_type*[T](dim: int): ptr julia_value =
  when T is int8:
    result = julia_apply_array_type_int8(dim.csize_t)
  elif T is int16:
    result = julia_apply_array_type_int16(dim.csize_t)
  elif T is int32:
    result = julia_apply_array_type_int32(dim.csize_t)
  elif T is int64:
    result = julia_apply_array_type_int64(dim.csize_t)
  elif T is uint8:
    result = julia_apply_array_type_uint8(dim.csize_t)
  elif T is uint16:
    result = julia_apply_array_type_uint16(dim.csize_t)
  elif T is uint32:
    result = julia_apply_array_type_uint32(dim.csize_t)
  elif T is uint64:
    result = julia_apply_array_type_uint64(dim.csize_t)
  elif T is float32:
    result = julia_apply_array_type_float32(dim.csize_t)
  elif T is float64:
    result = julia_apply_array_type_float64(dim.csize_t)
  elif T is bool:
    result = julia_apply_array_type_bool(dim.csize_t)
  elif T is char:
    result = julia_apply_array_type_char(dim.csize_t)
  else:
    doAssert(fals, "Type not supported")

proc julia_make_array*[T](data: ptr UncheckedArray[T], dims: openArray[int]): ptr julia_array =
  var dimStr = "("
  for d in dims:
    dimStr.add $d
    dimStr.add ","
  dimStr = dimStr & ")"
  var array_type: ptr julia_value = julia_apply_array_type[T](dims.len)
  result = julia_ptr_to_array(array_type, data, julia_eval_string(dimStr), 0.cint)

proc julia_alloc_array*[T](size: int) : ptr julia_array =
  var array_type: ptr julia_value = julia_apply_array_type[T](1)
  result = julia_alloc_array_1d(array_type, size.csize_t)

proc julia_alloc_array*[T](dim1, dim2: int) : ptr julia_array =
  var array_type: ptr julia_value = julia_apply_array_type[T](2)
  result = julia_alloc_array_2d(array_type, dim1.csize_t, dim2.csize_t)

proc julia_alloc_array*[T](dim1, dim2, dim3: int) : ptr julia_array =
  var array_type: ptr julia_value = julia_apply_array_type[T](3)
  result = julia_alloc_array_2d(array_type, dim1.csize_t, dim2.csize_t, dim3.csize_t)
