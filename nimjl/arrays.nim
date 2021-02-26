import config
import basetypes
import private/arrays_helpers
import private/basetypes_helpers

# TODO : Converter
proc toJlValue*[T](x: JlArray[T]): JlValue =
  result = cast[JlValue](x.data)

proc toJlArray*[T](x: JlValue): JlArray[T] =
  result.data = cast[ptr jl_array](x)

proc dataArray*[T](x: JlArray[T]): ptr UncheckedArray[T] =
  result = cast[ptr UncheckedArray[T]](jl_array_data(x.data))

proc len*[T](x: JlArray[T]): int =
  result = jl_array_len(x.data)

# Rank func takes value for some reason
proc ndims*[T](x: JlArray[T]): int =
  result = jl_array_rank(toJlValue(x))

proc dim*[T](x: JlArray[T], dim: int): int =
  result = jl_array_dim(x.data, dim.cint)

proc shape*[T](x: JlArray[T]): seq[int] =
  for i in 0..<x.ndims():
    result.add x.dim(i)

proc newJlArray*[T](data: ptr UncheckedArray[T], dims: openArray[int]): JlArray[T] =
  ## Create an Array from existing buffer
  result.data = julia_make_array[T](data, dims)

proc allocJlArray*[T](dims: openArray[int]): JlArray[T] =
  ## Create a Julia Array managed by Julia GC
  result.data = julia_alloc_array[T](dims)

