import config
import basetypes
import private/arrays_helpers
import private/basetypes_helpers

type JlArray*[T] = object
  data*: ptr julia_array
  datatype*: typedesc[T]

# TODO : Converter
proc toJlValue*[T](x: JlArray[T]): JlValue =
  result = cast[JlValue](x.data)

# TODO : Check if it's an array trhen converter
proc toJlArray*[T](x: JlValue): JlArray[T] =
  result.data = cast[ptr julia_array](x)

proc dataArray*[T](x: JlArray[T]): ptr UncheckedArray[T] =
  result = cast[ptr UncheckedArray[T]](julia_array_data(x.data))

proc len*(x: JlArray): int =
  result = julia_array_len(x.data)

proc ndims*(x: JlArray): int =
  result = julia_array_rank(x.data)

proc dim*(x: JlArray, dim: int): int =
  result = julia_array_dim(x.data, dim.cint)

proc shape*(x: JlArray): seq[int] =
  for i in 0..<x.ndims():
    result.add x.dim(i)

proc newJlArray*[T](data: ptr UncheckedArray[T], dims: openArray[int]): JlArray[T] =
  ## Create an Array from existing buffer
  result.data = julia_make_array[T](data, dims)

proc allocJlArray*[T](dims: openArray[int]): JlArray[T] =
  ## Create a Julia Array managed by Julia GC
  result.data = julia_alloc_array(T, dims)

