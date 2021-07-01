import std/unittest
import std/options
import std/tables
import std/sequtils

import nimjl

## Tuple stuff
proc tuplesTest() =
  block:
    var origtuple = (a: 123, b: some(-11.11e-3), c: 67.32147, d: some("azerty"), e: none(bool))
    var jl_tuple = toJlVal(origtuple)
    var ret = Julia.tupleTest(jl_tuple).to(bool)
    check ret

  block:
    var res = Julia.makeMyTuple().to(tuple[A: int, B: int, C: int])
    check res.A == 1
    check res.B == 2
    check res.C == 3

proc objectTest() =

  type MyStruct = object
    a: int
    b: Option[float]
    c: float
    d: Option[string]
    e: seq[int]

  block:
    var tt = MyStruct(a: 123, b: some(-11.11e-3), c: 67.32147, d: some("azerty"), e: @[1, 2, 3, 4, 5, 6])
    var jltt = tt.toJlVal()
    tt.e[0] = 111
    check $(jltypeof(jltt)) == "MyStruct"
    var ret = Julia.objectTest(jltt).to(bool)
    check ret
    var tt2 = jltt.to(MyStruct)
    check tt2 == tt

proc stringModTest() =
  var inputStr = "This is a nice string, isn't it ?"
  var res = Julia.modString(inputStr).to(string)
  check inputStr & " This is an amazing string" == res

proc tableToDictTest() =
  block StrNumTable:
    var
      key1 = "t0acq"
      val1 = 14
      key2 = "xOrigin"
      val2 = 3.48
      dict: Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var res = Julia.printDict(dict, key1, val1, key2, val2)
    check res.to(bool)

  block NumTable:
    var
      key1 = 11
      val1 = 14.144'f64
      key2 = 12
      val2 = 3.48'f64
      dict: Table[int, float64] = {key1: val1, key2: val2}.toTable
    var res = Julia.printDict(dict, key1, val1, key2, val2)
    check res.to(bool)

proc dictToTableTest() =
  block StrNumTable:
    var
      key1 = "t0acq"
      val1 = 14.0
      key2 = "xOrigin"
      val2 = 3.48
      dict: Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var jlres = Julia.`dictInvert!`(dict, key1, val1, key2, val2)
    var res = jlres.to(Table[string, float])
    check res[key1] == val2
    check res[key2] == val1

  block NumTable:
    var
      key1 = 11
      val1 = 14.144'f64
      key2 = 12
      val2 = 3.48'f64
      dict: Table[int, float64] = {key1: val1, key2: val2}.toTable
    var jlres = Julia.`dictInvert!`(dict, key1, val1, key2, val2)
    var res = jlres.to(Table[int, float])
    check res[key1] == val2
    check res[key2] == val1

proc nestedTuplesTest() =
  type
    A = tuple
      dict : Table[string, float32]
      dat: seq[int]

    B = tuple
      x: int
      y: int
      z: int

    O = tuple
      a: A
      b: B

  var o : O
  o.a = (dict: {"A": 1.0.float32,"B": 2.0.float32}.toTable, dat: toSeq(1..10))
  o.b = (x: 36, y: 48, z: 60)
  var res = Julia.nestedTuples(o)
  check res.to(bool)

proc runConversionsTest*() =
  suite "Conversions":
    teardown: jlGcCollect()

    test "Tuples":
      tuplesTest()

    test "Objects":
      objectTest()

    test "String":
      stringModTest()

    test "dictTest":
      tableToDictTest()

    test "invertDict":
      dictToTableTest()

    test "nestedTuples":
      nestedTuplesTest()

when isMainModule:
  import ./testfull
  Julia.init()
  runExternalsTest()
  runConversionsTest()
  Julia.exit()
