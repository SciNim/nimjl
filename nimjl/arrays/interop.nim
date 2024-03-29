import ../arrays
import ../types
import ../functions
import ../glucose
import ../conversions

import ../private/jlcores

import std/macros

import arraymancer

{.experimental: "views".}

# Utility
proc firstindex*[T](val: JlArray[T], dim: int): int =
  jlCall("firstindex", val, dim).to(int)

proc lastindex*[T](val: JlArray[T], dim: int): int =
  jlCall("lastindex", val, dim).to(int)

proc reshape*[T](x: JlArray[T], dims: JlArray[int]): JlArray[T] =
  result = jlCall("reshape", x, dims).toJlArray(T)

proc reshape*[T](x: JlArray[T], dims: openarray[int]): JlArray[T] =
  result = jlCall("reshape", x, dims).toJlArray(T)

proc reverse*[T](x: JlArray[T]): JlArray[T] =
  result = jlCall("reverse", x).toJlArray(T)

proc asType*[T](x: JlArray[T], U: typedesc): JlArray[U] =
  let tmp = newSeq[U](1).toJlArray()
  result = jlCall("convert", jltypeof(tmp), x).toJlArray(U)

proc stride*[T](x: JlArray[T], axis: int) : int =
  # Julia index starts at 1..
  result = jlCall("stride", x, axis+1).to(int)

proc strides*[T](x: JlArray[T]) : seq[int] =
  for i in 0..<x.ndims():
    result.add x.stride(i)

proc permutedims*[T](x: JlArray[T], dims: varargs[int]) : JlArray[T] =
  result = jlCall("permutedims", x, dims).toJlArray(T)

proc permutedDimsArray*[T](data: JlArray[T], dims: varargs[int]) : JlArray[T] =
  ## No copy dimension permutation
  result = jlCall("PermutedDimsArray", data, dims).toJlArray(T)

proc transpose*[T](x: JlArray[T]): JlArray[T] =
  # if x.ndims == 2:
  #   result = jlCall("transpose", x).toJlArray(T)
  # else:
  # Generalize transpose with permuteDimsArray
  let ndims = x.ndims
  var invdim = newSeq[int](ndims)
  for i in 0..<ndims:
    invdim[i] = ndims - i
  result = permutedDimsArray(x, invdim)

proc swapMemoryOrder*[T](x: JlArray[T]): JlArray[T] =
  let revshape = reverse(size(x))
  var invdim: seq[int]
  for i in countdown(ndims(x), 1):
    invdim.add i
  let tmp = reshape(x, revshape)
  result = permutedims(tmp, invdim)

proc unsafe_raw_offset*[T](x: JlArray[T], offset: int) : T =
  let jlptr = JlBase.pointer(x)
  result = jlCall("unsafe_load", jlptr, offset).to(T)

# # This section is copied from Arraymancer and Flambeau
# # ---------------------------------------------------------
# # Helpers proc
func getShape[T](s: openArray[T], parent_shape: seq[int] = @[]): seq[int] =
  ## Get the shape of nested seqs/arrays
  ## Important ⚠: at each nesting level, only the length
  ##   of the first element is used for the shape.
  ##   Ensure before or after that seqs have the expected length
  ##   or that the total number of elements matches the product of the dimensions.

  result = parent_shape
  result.add(s.len)

  when (T is seq|array):
    result = getShape(s[0], result)

macro getBaseType(T: typedesc): untyped =
  # Get the base T of a seq[T] input
  result = T.getTypeInst()[1]
  while result.kind == nnkBracketExpr and (
          result[0].eqIdent"seq" or result[0].eqIdent"array"):
    # We can also have nnkBracketExpr(Complex, float32)
    if result[0].eqIdent"seq":
      result = result[1]
    else: # array
      result = result[2]

iterator flatIter[T](s: openarray[T]): auto {.noSideEffect.} =
  ## Inline iterator on any-depth seq or array
  ## Returns values in order
  for item in s:
    when item is array|seq:
      for subitem in flatIter(item):
        yield subitem
    else:
      yield item

# ---------------------------------------------------------
# End of copyrighted section

# TODO GC-Root this OR Disable Julia GC and works with Nim GC
proc toJlArrayView*[T: SomeNumber](oa: openarray[T]): lent JlArray[T] =
  ## Interpret an openarray as a Julia Array
  ## Important:
  ##   the buffer is shared.
  ##   There is no copy but modifications are shared
  ##   and the view cannot outlive its buffer.
  ##
  ## Input:
  ##      - An array or a seq (can be nested)
  ## Result:
  ##      - A view Tensor of the same shape
  return jlArrayFromBuffer[T](oa)

proc toJlArray*[T: SomeNumber](oa: openarray[T]): JlArray[T] =
  ## Interpret an openarray as a Julia Array
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  let shape = getShape(oa)
  var addrInput = cast[ptr UncheckedArray[T]](unsafeAddr(oa[0]))

  var tmp = jlArrayFromBuffer(addrInput, shape)
  # var size: int
  # initTensorMetadata(tmp, size, tmp.shape, colMajor)
  result = swapMemoryOrder(tmp)


proc toJlArray*[T: seq|array](oa: openarray[T]): auto =
  ## Interpret an openarray as a Julia Array
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  let shape = getShape(oa)
  type BaseType = getBaseType(T)

  # var tmp = newTensorUninit[BaseType](shape)
  var tmp = allocJlArray[BaseType](shape)
  var data = tmp.getRawData()

  var i = 0
  for val in flatIter(oa):
    data[i] = val
    inc(i)

  result = swapMemoryOrder(tmp)

# Constructor

proc fill*[T](x: T, dims: varargs[int]): JlArray[T] =
  if dims.len > 0:
    result = jlCall("fill", x, dims).toJlArray(T)
  else:
    result = jlCall("fill", x).toJlArray(T)

proc rand*[T](dims: openArray[int]) : JlArray[T] =
  let
    tmp : T
    tmp2 = tmp.toJlValue()

  jlCall("rand", jltypeof(tmp2), dims)


