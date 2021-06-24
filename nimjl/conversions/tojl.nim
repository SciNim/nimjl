import ../private/jlcores
import ../cores
import ../types
import ../arrays

import ./box

import std/json
import std/tables
import std/options
import arraymancer

{.push inline.}

# Is converter appropriate ?
converter nimValueToJlValue*[T](x: JlArray[T]): JlValue = cast[JlValue](x)
converter nimValueToJlValue*(x: JlSym): JlValue = cast[JlValue](x)
converter nimValueToJlValue*(x: JlDataType): JlValue = cast[JlValue](x)
converter nimValueToJlValue*(x: JlFunc): JlValue = cast[JlValue](x)
converter nimValueToJlValue*(x: JlModule): JlValue = cast[JlValue](x)
proc nimValueToJlValue(x: JlValue): JlValue = x

# Real conversions
proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue =
  result = jlvalue_from_string(val)

# Forward declaration for cyclic import
proc nimValueToJlValue(x: tuple): JlValue
proc nimValueToJlValue(x: object): JlValue
proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue
proc nimValueToJlValue[T](x: Option[T]): JlValue

proc nimValueToJlValue[T](x: openarray[T]): JlValue =
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

proc nimValueToJlValue[I, T](x: array[I, T]): JlValue =
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

proc nimValueToJlValue[T](x: Tensor[T]): JlValue =
  ## Convert a Tensor to JlValue
  result = nimValueToJlValue(
    jlArrayFromBuffer(x)
  )

{.pop.}

# Public API
proc toJlVal*[T](x: T): JlValue =
  ## Convert a generic Nim type to a JlValue
  nimValueToJlValue(x)

proc toJlValue*[T](x: T): JlValue =
  ## Alias for toJlVal
  ## Added for consistency with JlValue type name
  toJlVal[T](x)

# Recursive import strategy
import ./dict_tuples
import ./obj_structs

proc nimValueToJlValue(x: object): JlValue =
  nimToJlVal(x)

proc nimValueToJlValue[T](x: Option[T]): JlValue =
  if isSome(x):
    result = toJlVal(get(x))
  else:
    result = JlNothing

proc nimValueToJlValue(x: tuple): JlValue =
  result = nimToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue =
  result = nimTableToJlDict(x)

