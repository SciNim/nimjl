import config
import basetypes
import boxunbox
import dicttuples
import arrays

import json
import tables
import arraymancer

{.push inline.}
## Julia -> Nim
proc toNimVal[T: SomeNumber|bool|pointer|string](x: JlValue, res: var T) =
  when T is string:
    res = jlValToString(x)
  else:
    res = jlUnbox[T](x)

# Julia Tuple / Dict can't really be mapped to Nim's type so returning JsonNode is easier.
# It introduces a "distinction" between to[T] -> T and to[T] -> JsonNode as return types
proc toNimVal(x: JlValue, t: var tuple) =
  jlTupleToNim(x, t)

proc toNimVal[U, V](x: JlValue, tab: var Table[U, V]) =
  jlDictToNim[U, V](x, tab)

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
    let nbytes: int = x.len()*sizeof(T) div sizeof(byte)
    copyMem(tensor.get_offset_ptr(), x.getRawData(), nbytes)

proc toNimVal[T](x: JlValue, locseq: var seq[T]) =
  # Tensor tmp version
  # var tmp : Tensor[T]
  # toNimVal(x, tmp)
  # locseq = tmp.toSeq
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
proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue =
  result = nimStringToJlVal(val)

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

proc nimValueToJlValue(x: JlValue): JlValue  =
  result = x

# Complex stuff
proc nimValueToJlValue(x: tuple): JlValue  =
  result = nimToJlTuple(x)

# Treat Nim object as Julia tuple
proc nimValueToJlValue(x: object): JlValue  =
  result = nimToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue  =
  result = nimTableToJlDict(x)

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

{.pop.}
