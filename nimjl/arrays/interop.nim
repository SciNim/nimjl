import ../arrays
import ../types
import ../cores

import ../private/jlarrays
import ../private/jlcores

import std/macros
import std/sequtils

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

proc product[T](s: seq[T]): T =
  foldl(s, a*b)
# ---------------------------------------------------------
# End of copyrighted section

# TODO GC-Root this OR Disable Julia GC and works with Nim GC
proc toJlArrayView*[T](oa: openarray[T]): lent JlArray[T] =
  ## Interpret an openarray as a CPU Tensor
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
  ## Interpret an openarray as a CPU Tensor
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  # toArrayFromScalar[T](oa).toJlArray[T]()
  let shape = getShape(oa)
  let nbytes = shape.product()*(sizeof(T) div sizeof(byte))
  result = allocJlArray[T](shape)
  copyMem(unsafeAddr(result.getRawData()[0]), unsafeAddr(oa[0]), nbytes)

proc toJlArray*[T: seq|array](oa: openarray[T]): auto =
  ## Interpret an openarray as a CPU Tensor
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  let shape = getShape(oa)
  let nbytes = shape.product()*(sizeof(T) div sizeof(byte))
  type BaseType = getBaseType(T)
  var res = allocJlArray(shape, BaseType)
  copyMem(cast[ptr jl_array](res).jl_array_data(), unsafeAddr(oa[0]), nbytes)
  arrays.toJlArray(res, BaseType)

proc firstindex*[T](val: JlArray[T], dim: int) : int =
  Julia.firstindex(val, dim).to(int)

proc lastindex*[T](val: JlArray[T], dim: int) : int =
  Julia.lastindex(val, dim).to(int)

proc iterate*[T](val: JlArray[T]): JlValue =
  result = JlMain.iterate(val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable Array. This shouldn't be possible, but reality and life are often strange.")

proc iterate*[T](val: JlArray[T], state: JlValue): JlValue =
  result = JlMain.iterate(val, state)

iterator items*[T](val: JlArray[T]): T =
  var it = iterate(val)
  while it != JlNothing:
    yield it.getindex(1).to(T)
    it = iterate(val, it.getindex(2))

iterator enumerate*[T](val: JlArray[T]): (int, T) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it.getindex(1).to(T))
    it = iterate(val, it.getindex(2))
    inc(i)
