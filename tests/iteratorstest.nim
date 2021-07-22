import unittest
import std/sequtils

import nimjl

proc arrayIterator() =
  block:
    var xx = toSeq(0..<10).toJlArray()
    var i = 0
    for x in xx:
      check x == i
      inc(i)
  block:
    var refxx = toSeq(0..<10)
    var xx = toSeq(0..<10).toJlArray()
    var refi = 0
    for i, x in enumerate(xx):
      check i == refi
      check x == refxx[i]
      inc(refi)

proc tupleIterator() =
  var xx = (1, 3, 5, 7, 9, 11,).toJlValue()
  block:
    var refx = 1
    for x in xx:
      check x.to(int) == refx
      inc(refx)
      inc(refx)

  block:
    var refi = 0
    var refxx = @[1, 3, 5, 7, 9, 11]
    for i, x in enumerate(xx):
      check i == refi
      check x.to(int) == refxx[i]
      check x == toJlValue(refxx[i])
      inc(refi)

proc runIteratorsTest*() =
  suite "Iterators":
    teardown: jlGcCollect()
    test "Array Iterators":
      arrayIterator()
    test "Tuple Iterators":
      tupleIterator()

when isMainModule:
  import ./testfull
  Julia.init()
  runExternalsTest()
  runIteratorsTest()
