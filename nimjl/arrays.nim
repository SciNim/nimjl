import ./types
import ./functions
import ./conversions/unbox
import ./conversions/box
import ./private/jlcores
import ./private/jlarrays

import arraymancer
import std/algorithm

proc tensor_shape[T](x: Tensor[T]): seq[int] =
  # toSeq was causing issue for some reason and I don't want to import some of Arraymancer Metadata here
  var curShape = -1
  var idx = 0
  curShape = x.shape[idx]
  while curShape != 0:
    result.add curShape
    inc(idx)
    curShape = x.shape[idx]

proc toJlArray*[T](x: JlValue): JlArray[T] {.inline.} =
  result = cast[ptr jl_array](x)

proc toJlArray*(x: JlValue, T: typedesc): JlArray[T] {.inline.} =
  result = cast[ptr jl_array](x)

proc getRawData*[T](x: JlArray[T]): ptr UncheckedArray[T] {.inline.} =
  result = cast[ptr UncheckedArray[T]](jl_array_data(x))

proc len*[T](x: JlArray[T]): int =
  result = jl_array_len(x)

# Rank func takes value for some reason
proc ndims*[T](x: JlArray[T]): int =
  # This version was buggy w/ indexing macro
  # That's because raw C function works on Base.Array but may not work on higher level Array-like type
  # dim have the same issue
  # result = jl_array_rank(cast[JlValue](x))
  result = jlUnbox[int](jlCall("ndims", x))

proc dim*[T](x: JlArray[T], dim: int): int =
  result = jl_array_dim(x, dim.cint)

proc size*[T](x: JlArray[T]): JlArray[int] =
  result = jlCall("size", cast[JlValue](x)).toJlArray(int)

proc size*[T](x: JlArray[T], dim: int): int =
  result = jlUnbox[int](
    jlCall("size", cast[JlValue](x), jlBox(dim))
  )

proc shape*[T](x: JlArray[T]): seq[int] =
  for i in 1..x.ndims():
    result.add size(x, i)

proc eltype*[T](x: JlArray[T]): JlDataType =
  jl_array_eltype(cast[JlValue](x))

# Buffer with dims
proc jlArrayFromBuffer*[T](data: ptr UncheckedArray[T], dims: openArray[int]): JlArray[T] =
  ## Create an Array from existing buffer
  result = julia_make_array[T](data, dims)

# Seq/array mapped to 1D
proc jlArrayFromBuffer*[T](data: openArray[T]): JlArray[T] =
  ## Create an Array from existing buffer
  let uncheckedDataPtr = cast[ptr UncheckedArray[T]](data[0].unsafeAddr)
  result = jlArrayFromBuffer(uncheckedDataPtr, [data.len()])

proc jlArrayFromBuffer*[T](data: Tensor[T]): JlArray[T] =
  if not is_contiguous(data):
    raise newException(ValueError, "Error using non-contiguous Tensor as buffer")

  ## Create an Array from existing buffer
  let uncheckedDataPtr = data.toUnsafeView()
  let shape = data.tensor_shape
  result = jlArrayFromBuffer[T](uncheckedDataPtr, shape)

# Julia allocated array
proc allocJlArray*[T](dims: openArray[int]): JlArray[T] =
  ## Create a Julia Array managed by Julia GC
  result = julia_alloc_array(dims, T)

# Julia allocated array
proc allocJlArray*(dims: openArray[int], T: typedesc): JlValue =
  ## Create a Julia Array managed by Julia GC
  result = cast[JlValue](julia_alloc_array(dims, T))

proc toJlArray*[T](x: Tensor[T]): JlArray[T] =
  if not is_contiguous(x):
    raise newException(ValueError, "Error using non-contiguous Tensor as buffer")

  let shape = x.tensor_shape
  result = allocJlArray[T](shape)
  var tmp = fromBuffer(result.getRawData(), shape)
  var size: int
  initTensorMetadata(tmp, size, tmp.shape, colMajor)
  apply2_inline(tmp, x):
    y

import ./arrays/interop
export interop

import ./arrays/indexing
export indexing

import ./arrays/dotoperators
export dotoperators
