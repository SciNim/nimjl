import ../types
import ../cores
import ../functions
import ../conversions

import ../glucose
import ./valindexing

import std/strutils

proc iterate[T](val: JlArray[T]): JlValue =
  result = jlCall("iterate", val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable Array. This shouldn't be possible.")

proc iterate[T](val: JlArray[T], state: JlValue): JlValue =
  result = jlCall("iterate", val, state)

iterator items*[T](val: JlArray[T]): T =
  var it = iterate(val)
  while it != JlNothing:
    yield it[1].to(T)
    it = iterate(val, it[2])

iterator enumerate*[T](val: JlArray[T]): (int, T) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it[1].to(T))
    it = iterate(val, it[2])
    inc(i)

proc iterate(val: JlValue): JlValue =
  result = jlCall("iterate", val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable value")

proc iterate(val: JlValue, state: JlValue): JlValue =
  result = jlCall("iterate", val, state)

iterator items*(val: JlValue): JlValue =
  var it = iterate(val)
  while it != JlNothing:
    yield it[1]
    it = iterate(val, it[2])

iterator enumerate*(val: JlValue): (int, JlValue) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it[1])
    it = iterate(val, it[2])
    inc(i)

iterator pairs*(val: JlValue): (string, JlValue) =
  var keys = jlCall("keys", val)
  var show = getJlFunc("show")
  var sprint = getJlFunc("sprint")

  var i = 0
  var it = iterate(val)
  while it != JlNothing:
    var
      key = jlCall("getindex", keys, i+1)
      keyName = jlCall(sprint, show, key).to(string)
    removePrefix(keyName, ':')

    yield (keyname, it[1])
    it = iterate(val, it[2])
    inc(i)
