import unittest
import sequtils
import options
import tables
import sugar

import nimjl

import ./indexingtests
import ./iteratorstests
import ./arraymancertensortests

proc simpleEvalString() =
  var test = jlEval("sqrt(4.0)")
  check jlUnbox[float64](test) == 2.0

proc boxUnbox() =
  block:
    var orig: float64 = 126545836.31266
    var x = jlBox[float64](orig)
    check jlUnbox[float64](x) == orig

  block:
    var orig: float32 = 0.01561238536
    var x = jlBox[float32](orig)
    check jlUnbox[float32](x) == orig

  block:
    var orig: int8 = -121
    var x = jlBox[int8](orig)
    check jlUnbox[int8](x) == orig

  block:
    var orig: uint8 = 251
    var x = jlBox[uint8](orig)
    check jlUnbox[uint8](x) == orig

proc callJulia() =
  block:
    var x = jlBox[float64](4.0)
    check jlUnbox[float64](x) == 4.0
    var f = getJlFunc(JlBase, "sqrt");
    var res = jlCall(f, x)
    check jlUnbox[float64](res) == 2.0

  block:
    var res = JlBase.sqrt(4.0)
    check res == toJlValue(2.0)
    check jlUnbox[float64](res) == 2.0

proc runSimpleTests() =
  suite "Basic stuff":
    teardown: jlGcCollect()
    test "nim_eval_string":
      simpleEvalString()

    test "box_unbox":
      boxUnbox()

    test "jlCall":
      callJulia()



proc jlArray1D() =
  let ARRAY_LEN = 1000
  var orig: seq[float64] = toSeq(0..<1500).map(x => x.float64)

  var x: JlArray[float64]
  x = allocJlArray[float64]([ARRAY_LEN])
  # Root the value
  jlGcRoot(x):
    # julia_gc_push1(addr(x))
    var xData = getRawData[float64](x)
    check ARRAY_LEN == len(x)
    for i in 0..<len(x):
      xData[i] = i.float64

    var res = Julia.`reverse!`(x)
    check not isNil(res)

    var resData = toJlArray[float64](res).getRawData()
    check resData == xData

    for i in 0..<ARRAY_LEN:
      check xData[i] == orig[ARRAY_LEN - i - 1]
  # julia_gc_pop()

proc jlArrayFromSeq() =
  var orig: seq[int] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  var res = Julia.`reverse!`(orig)
  check not isNil(res)

  var resData = toJlArray[int](res).getRawData()
  for i in 0..<orig.len:
    check resData[i] == orig[i]

  # Check reverse
  for i in 0..<orig.len():
    check orig[i] == int(orig.len() - i - 1)

proc run1DArrayTest*() =

  suite "Array 1D":
    teardown: jlGcCollect()

    test "jl_array_1d":
      jlArray1D()

    test "jl_array_1d_own_buffer":
      jlArrayFromSeq()

## Tuple stuff
proc tuplesTest() =
  block:
    var origtuple = (a: 123, b: some(-11.11e-3), c: 67.32147, d: some("azerty"), e: none(bool))
    var jl_tuple = toJlVal(origtuple)
    var ret = jlCall("tupleTest", jl_tuple).to(bool)
    check ret

  block:
    var res = jlCall("makeMyTuple").to(tuple[A: int, B: int, C: int])
    check res.A == 1
    check res.B == 2
    check res.C == 3

  type TT = object
    a: int
    b: Option[float]
    c: float
    d: Option[string]
    e: Option[bool]

  block:
    var tt: TT = TT(a: 123, b: some(-11.11e-3), c: 67.32147, d: some("azerty"), e: none(bool))
    var ret = jlCall("tupleTest", tt).to(bool)
    check ret

proc stringModTest() =
  var inputStr = "This is a nice string, isn't it ?"
  var res: string = jlCall("modString", inputStr).to(string)
  check inputStr & " This is an amazing string" == res

proc tableToDictTest() =
  block StrNumTable:
    var
      key1 = "t0acq"
      val1 = 14
      key2 = "xOrigin"
      val2 = 3.48
      dict: Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var res = jlCall("printDict", dict, key1, val1, key2, val2)
    check res.to(bool)

  block NumTable:
    var
      key1 = 11
      val1 = 14.144'f64
      key2 = 12
      val2 = 3.48'f64
      dict: Table[int, float64] = {key1: val1, key2: val2}.toTable
    var res = jlCall("printDict", dict, key1, val1, key2, val2)
    check res.to(bool)

proc dictToTableTest() =
  block StrNumTable:
    var
      key1 = "t0acq"
      val1 = 14.0
      key2 = "xOrigin"
      val2 = 3.48
      dict: Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var jlres = jlCall("dictInvert!", dict, key1, val1, key2, val2)
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
    var jlres = jlCall("dictInvert!", dict, key1, val1, key2, val2)
    var res = jlres.to(Table[int, float])
    check res[key1] == val2
    check res[key2] == val1

proc nestedObjectsTest() =
  type
    A = object
      dict : Table[string, float32]
      dat: seq[int]

    B = tuple
      x: int
      y: int
      z: int

    O = object
      a: A
      b: B

  var o : O
  o.a = A(dict: {"A": 1.0.float32,"B": 2.0.float32}.toTable, dat: toSeq(1..10))
  o.b = (x: 36, y: 48, z: 60)
  var res = jlCall("nestedObjects", o)
  check res.to(bool)

proc runTupleTest*() =
  suite "Tuples":
    teardown: jlGcCollect()

    test "tupleTest":
      tuplesTest()

    test "modString":
      stringModTest()

    test "dictTest":
      tableToDictTest()

    test "invertDict":
      dictToTableTest()

    test "nestedObjectsTuples":
      nestedObjectsTest()

### Externals module & easy stuff
proc includeExternalModule() =
  jlInclude("tests/test.jl")
  jlUseModule(".custom_module")

proc callDummyFunc() =
  var ret = jlCall("dummy")
  check not isNil(ret)

### Array args
proc arraySquareMeBaby() =
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]

  var
    jlret = jlCall("squareMeBaby", orig)
    ret = toJlArray[float64](jlret)
    len_ret = len(ret)
    rank_ret = ndims(ret)
  check len_ret == orig.len
  check rank_ret == 1

  var seqData = jlret.to(seq[float64])
  check seqData == @[0.0, 1.0, 4.0, 9.0, 16.0, 25.0, 36.0, 49.0, 64.0, 81.0]

proc arrayMutateMeBaby() =

  var
    orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
    data: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
    xArray = jlArrayFromBuffer[float64](data)
  check not isNil(xArray)

  var
    ret = jlCall("mutateMeByTen!", xArray)
    len_ret = len(xArray)
    rank_ret = ndims(xArray)

  check not isNil(ret)
  check len_ret == orig.len
  check rank_ret == 1
  check data == @[0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0]
  check data == orig.map(x => x*10)

proc runArrayArgsTest*() =
  suite "Array":
    teardown: jlGcCollect()

    test "external_module : squareMeBaby[Array]":
      arraySquareMeBaby()

    test "external_module : mutateMeByTen[Array]":
      arrayMutateMeBaby()

proc runExternalsTest*() =
  suite "external module":
    teardown: jlGcCollect()
    test "external_module":
      includeExternalModule()

    test "dummy":
      callDummyFunc()

proc runTests*() =
  # run Externals include module so ran it first and only once
  runExternalsTest()
  runSimpleTests()
  runTupleTest()
  run1DArrayTest()
  runArrayArgsTest()
  runTensorArgsTest()
  runIteratorsTest()
  runIndexingTest()

when defined(checkMemLeak):
  import memleaktest

when isMainModule:
  Julia.init()
  runTests()
  when defined(checkMemLeak):
    runMemLeakTest()
  Julia.exit()

