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

  # Nim -> Julia
# Avoid going throung template toJlVal pointer version when dealing with Julia known type
# Is converter the right choice here ?
converter nimValueToJlValue*[T](x: JlArray[T]): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlSym): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlDataType): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlFunc): JlValue =
  result = cast[JlValue](x)

converter nimValueToJlValue(x: JlModule): JlValue =
  result = cast[JlValue](x)

proc nimValueToJlValue*[T: SomeNumber|bool|pointer](val: T): JlValue =
  result = jlBox(val)

proc nimValueToJlValue(val: string): JlValue =
  result = jlvalue_from_string(val)

proc nimValueToJlValue(x: JlValue): JlValue =
  result = x

# Forward declaration for cyclic import
proc nimValueToJlValue(x: tuple): JlValue
proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue
proc nimValueToJlValue[T](x: Option[T]): JlValue

# TODO object as struct
# proc nimValueToJlValue(x: object): JlValue

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
proc nimValueToJlValue[T](x: Option[T]): JlValue =
  if isSome(x):
    result = toJlVal(get(x))
  else:
    result = JlNothing

proc nimValueToJlValue(x: tuple): JlValue =
  result = nimToJlTuple(x)

proc nimValueToJlValue[U, V](x: Table[U, V]): JlValue =
  result = nimTableToJlDict(x)

