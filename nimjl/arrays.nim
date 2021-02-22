import config
import basetypes
import private/arrays_helpers

type ArrayNimjl[T] = object
  data: ptr nimjl_array
  types: T

proc jlValue*[T](x: ArrayNimjl[T]): ptr nimjl_value =
  result = cast[ptr nimjl_value](x.data)

proc jlData*[T](x: ArrayNimjl[T]): ptr UncheckedArray[T] =
  result = cast[ptr UncheckedArray[T]](nimjl_array_data(x.data))

proc len*[T](x: ArrayNimjl): int =
  result = nimjl_array_len(x.data)

proc ndims*[T](x: ArrayNimjl): int =
  result = nimjl_array_rank(x.data)

# Alias for quality of life stuff
proc rank*[T](x: ArrayNimjl): int = ndims

proc nimjl_make_array[T](data: ptr UncheckedArray[T], dims: openArray[int]): ptr nimjl_array =
  var dimStr = "("
  for d in dims:
    dimStr.add $d
    dimStr.add ","
  dimStr = dimStr & ")"
  var array_type: ptr nimjl_value = nimjl_apply_array_type[T](dims.len)
  result = nimjl_ptr_to_array(array_type, data, nimjl_eval_string(dimStr), 0.cint)

proc newArrayNimjl*[T](data: ptr UncheckedArray, dims: openArray[int]) : ArrayNimjl[T] =
  result.data = nimjl_make_array[T](data, dims)
  result.types = T


