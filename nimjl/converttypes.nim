import config
import basetypes
import boxunbox
import dicttuples

import json
import tables

## Julia -> Nim

# Tuple becomes Json ?
# Dict become Table or Json ?

proc toNimVal*[T: SomeNumber|bool|pointer|string](x: JlValue, res: var T) =
  when T is string:
    res = jlValToString(x)
  else:
    res = jlUnbox[T](x)

# Julia Tuple / Dict can't really be mapped to Nim's type so returning JsonNode is easier.
# It introduces a "distinction" between to[T] -> T and to[T] -> JsonNode as return types
proc toNimVal*(x: JlValue, t: var tuple) =
  jlTupleToNim(x, t)

proc toNimVal*[U, V](x: JlValue, tab: var Table[U, V]) =
  jlDictToNim[U, V](x, tab)

proc to*(x: JlValue, T: typedesc): T =
  when T is void:
    discard
  else:
    toNimVal(x, result)

## Nim -> Julia
proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue {.inline.} =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue {.inline.} =
  result = nimStringToJlVal(val)

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
  result = nimToJlTuple(x)

proc nimValueToJlValue(x: object): JlValue {.inline.} =
  result = nimToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue {.inline.} =
  result = nimTableToJlDict(x)

# Generic API
template toJlVal*[T](x: T): JlValue =
  nimValueToJlValue(x)

