import ../private/jlcores
import ../cores
import ../types
import ../arrays

import ./boxunbox

import std/json
import std/tables
import std/options
import arraymancer

{.push inline.}

## Julia -> Nim
proc toNimVal[T: SomeNumber|bool|pointer](x: JlValue, res: var T) =
  res = jlUnbox[T](x)

proc toNimVal(x: JlValue, res: var string) =
  res = jlvalue_to_string(x)

# Julia Tuple / Dict can't really be mapped to Nim's type so returning JsonNode is easier.
# It introduces a "distinction" between to[T] -> T and to[T] -> JsonNode as return types
# Forward declare for cyclic import
proc toNimVal(x: JlValue, t: var tuple)
proc toNimVal[U, V](x: JlValue, tab: var Table[U, V])

proc toNimVal[T](x: JlValue, tensor: var Tensor[T]) =
  let x = toJlArray[T](x)
  # This is possible but relies on keep Julia's memory intact
  # I believe a copyMem is cleaner and safer
  # tensor = fromBuffer(x, x.shape)
  # Version that doesn't rely on keepin Jl array alive
  if x.ndims > 6:
    raise newException(JlError, "Tensor only support up to 6 dimensions")
  tensor = newTensor[T](x.shape)
  if x.len > 0:
    # Can create a view as well
    let tmp = fromBuffer[T](x.getRawData(), x.shape())
    tensor = tmp.clone()
    # let nbytes: int = x.len()*sizeof(T) div sizeof(byte)
    # copyMem(tensor.get_offset_ptr(), x.getRawData(), nbytes)

proc toNimVal[T](x: JlValue, locseq: var seq[T]) =
  let x = toJlArray[T](x)
  if x.ndims > 1:
    raise newException(JlError, "Can only convert 1D Julia Array to Nim seq")
  let nbytes: int = x.len()*sizeof(T) div sizeof(byte)
  locseq.setLen(x.len())
  if x.len() > 0:
    copyMem(unsafeAddr(locseq[0]), x.getRawData(), nbytes)

proc toNimVal[I, T](x: JlValue, locarr: var array[I, T]) =
  let x = toJlArray[T](x)
  if x.ndims > 1:
    raise newException(JlError, "Can only convert 1D Julia Array to Nim seq")
  let nbytes: int = x.len()*sizeof(T) div sizeof(byte)
  if x.len() > 0:
    copyMem(unsafeAddr(locarr[0]), x.rawData(), nbytes)

# Nim -> Julia
# Avoid going throung template toJlVal pointer version when dealing with Julia known type
# Is converter the right choice here ?
converter nimValueToJlValue*[T](x: JlArray[T]): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlSym): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlFunc): JlValue  =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlModule): JlValue  =
  result = cast[JlValue](x)

proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue =
  result = jlvalue_from_string(val)

proc nimValueToJlValue(x: JlValue): JlValue  =
  result = x

# Complex stuff
# Treat Nim object as Julia tuple
# Forward declaration for cyclic import
proc nimValueToJlValue(x: tuple): JlValue
proc nimValueToJlValue(x: object): JlValue
proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue
proc nimValueToJlValue[T](x: Option[T]): JlValue

proc nimValueToJlValue[T](x: seq[T]): JlValue  =
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

proc nimValueToJlValue[I, T](x: array[I, T]): JlValue  =
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

proc nimValueToJlValue[T](x: Tensor[T]): JlValue  =
  ## Convert a Tensor to JlValue
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

# Public API
proc to*(x: JlValue, T: typedesc): T =
  ## Copy a JlValue into a Nim type
  when T is void:
    discard
  else:
    toNimVal(x, result)

proc toJlVal*[T](x: T): JlValue =
  ## Convert a generic Nim type to a JlValue
  nimValueToJlValue(x)

proc toJlValue*[T](x: T): JlValue =
  ## Alias for toJlVal
  ## Added for consistency with JlValue type name
  toJlVal[T](x)

# Recursive import strategy
import ./dicttuples

proc toNimVal(x: JlValue, t: var tuple) =
  jlTupleToNim(x, t)

proc toNimVal[U, V](x: JlValue, tab: var Table[U, V]) =
  jlDictToNim[U, V](x, tab)

proc nimValueToJlValue[T](x: Option[T]): JlValue  =
  if isSome(x):
    result = toJlVal(get(x))
  else:
    result = jlEval("nothing")

proc nimValueToJlValue(x: tuple): JlValue  =
  result = nimToJlTuple(x)

# Treat Nim object as Julia tuple
proc nimValueToJlValue(x: object): JlValue  =
  result = nimToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue  =
  result = nimTableToJlDict(x)

{.pop.}

export boxunbox
export dicttuples
