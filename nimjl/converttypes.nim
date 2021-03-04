import config
import basetypes
import arrays

import strutils
import json
import tables
import strutils
import strformat


# Tuple helpers -> result is memory managed by Julia's GC
proc jlTuple*(v: tuple): JlValue =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = jlEval(tupleStr)

proc jlTuple*(v: object): JlValue =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = jlEval(tupleStr)

proc jlDict*(json: JsonNode): JlValue =
  var dictStr = "Dict(["
  for k, v in json:
    dictStr.add &"(\"{k}\",{v}),"
  dictStr = dictStr.strip(chars = {','})
  dictStr.add "])"
  result = jlEval(dictStr)

proc jlDict*[T](tab: Table[string, T]): JlValue =
  let json = %tab
  var dictStr = "Dict(["
  for k, v in json:
    dictStr.add &"(\"{k}\",{v}),"
  dictStr = dictStr.strip(chars = {','})
  dictStr.add "])"
  result = jlEval(dictStr)

proc jlDict*[U, V](tab: Table[U, V]): JlValue =
  var dictStr = "Dict(["
  for k, v in tab:
    dictStr.add &"({k}, {v}),"
  dictStr = dictStr.strip(chars = {','})
  dictStr.add "])"
  result = jlEval(dictStr)

proc toJlDict*[U, V](val: JlValue): Table[U, V] =
  result = initTable[U, V]()

###### Public API
# TODO complete Missing useful types : Tuple, Object, enum, Seq/Arrays
template to*[T](x: JlValue, t: typedesc[T]): t =
  when T is string:
    jlValToString(x)
  elif T is JsonNode:
    doAssert(false, "JsonNode Not implemented")
  elif T is Table:
    doAssert(false, "Table Not implemented")
  elif T is object:
    doAssert(false, "object Not implemented")
  elif T is tuple:
    doAssert(false, "Tuples Not implemented")
  else:
    jlUnbox[t](x)

## to(ptr UncheckedArray[float64]) is not very intuitve. Use dataArray[float64] instead
template to*[T](x: JlValue, t: typedesc[ptr UncheckedArray[T]]): ptr UncheckedArray[T] =
  toJlArray(x).dataArray()

proc nimValueToJlValue*[T](val: T): JlValue {.inline.} =
  when T is string:
    result = nimStringToJlVal(val)
  elif T is JsonNode:
    result = jlDict(val)
  elif T is Table:
    result = jlDict(val)
  elif T is JsonNode:
    doAssert(false, "JsonNode Not implemented")
  elif T is Table:
    doAssert(false, "Table Not implemented")
  elif T is object:
    result = jlTuple(val)
  elif T is tuple:
    result = jlTuple(val)
  else:
    result = jlBox(val)

proc nimValueToJlValue*[T](val: ptr UncheckedArray[T]): JlValue {.inline.} =
  result = newJlArray(unsafeAddr(val[0]))

template toJlVal*[T](x: T): JlValue =
  nimValueToJlValue(x)
