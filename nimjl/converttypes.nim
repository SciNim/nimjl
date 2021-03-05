import config
import basetypes
import boxunbox
import dicttuples
import arrays

import json
import tables

# TODO complete Missing useful types : Tuple, Object, enum, Seq/Arrays
## Julia -> Nim

# Tuple becomes Json ?
proc jlTupleToNim*[T: tuple](x: JlValue, t: typedesc[T]): JsonNode =
  # jlTupleToNim(x)
  doAssert(false, "Tuple Not implemented")

# Dict become Table or Json ?
proc toNimVal*[U, V](x: JlValue, t: typedesc[Table[U, V]]): Table[U, V] =
  doAssert(false, "Table Not implemented")

proc toNimVal*[T: SomeNumber|bool|pointer|string](x: JlValue): T =
  when T is string:
    jlValToString(x)
  else:
    jlUnbox[T](x)

# Julia Tuple / Dict can't really be mapped to Nim's type so returning JsonNode is easier.
# It introduces a "distinction" between to[T] -> T and to[T] -> JsonNode as return types
proc to*[T: tuple|Table](x: JlValue, t: typedesc[T]): JsonNode =
  doAssert(false, "Tuple/Table from JlValue not implemented")

template to*[T](x: JlValue, t: typedesc[T]): T =
  toNimVal[T](x)

## Nim -> Julia
proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue {.inline.} =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue {.inline.} =
  result = nimStringToJlVal(val)

proc nimValueToJlValue(val: object): JlValue {.inline.} =
  doAssert(false, "Object Not implemented")

proc nimValueToJlValue[T](val: ptr UncheckedArray[T]): JlValue {.inline.} =
  result = newJlArray(unsafeAddr(val[0]))

# Avoid going throung template toJlVal pointer version when dealing with Julia known type
# Declare toJlVal here to avoir circular dependencies
proc nimValueToJlValue*[T](x: JlArray[T]): JlValue {.inline.} =
  result = cast[JlValue](x)

proc nimValueToJlValue(x: JlSym): JlValue {.inline.} =
  result = cast[JlValue](x)

proc nimValueToJlValue(x: JlFunc): JlValue {.inline.} =
  result = cast[JlValue](x)

proc nimValueToJlValue(x: JlModule): JlValue {.inline.} =
  result = cast[JlValue](x)

proc nimValueToJlValue(x: JlValue): JlValue {.inline.} =
  result = x

proc nimValueToJlValue(x: tuple): JlValue {.inline.} =
  result = nimTupleToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue {.inline.} =
  result = nimTableToJlDict(x)

# Generic API
template toJlVal*[T](x: T): JlValue =
  nimValueToJlValue(x)


