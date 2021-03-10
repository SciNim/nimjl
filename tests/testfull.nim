import unittest
import sequtils
import tables
import sugar

import arraymancer
import nimjl

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
  var x = jlBox[float64](4.0)
  var f = getJlFunc(jl_base_module, "sqrt");
  var res = jlCall(f, x)
  check jlUnbox[float64](res) == 2.0
  check jlUnbox[float64](x) == 4.0

proc runSimpleTests() =
  suite "Basic stuff":
    teardown: jlGcCollect()
    test "nim_eval_string":
      simpleEvalString()

    test "box_unbox":
      boxUnbox()

    test "jl_call1":
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

    var reverse = getJlFunc(jl_base_module, "reverse!")
    var res = jlCall(reverse, x)
    check not isNil(res)

    var resData = toJlArray[float64](res).getRawData()
    check resData == xData

    for i in 0..<ARRAY_LEN:
      check xData[i] == orig[ARRAY_LEN - i - 1]
  # julia_gc_pop()

proc jlArrayFromSeq() =
  var orig: seq[int] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  var res = jlCall("reverse!", orig)
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
    var jl_tuple = (a: 124, c: 67.32147)
    var ret = jlCall("tupleTest", jl_tuple).to(bool)
    check ret

  block:
    var res = jlCall("makeMyTuple").to(tuple[A: int, B: int, C: int])
    check res.A == 1
    check res.B == 2
    check res.C == 3

  type TT = object
    a: int
    c: float

  block:
    var tt: TT = TT(a: 124, c: 67.32147)
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

### Tensor Args
proc tensorSquareMeBaby() =
  let dims = [18, 21, 33]
  var
    orig: Tensor[float64] = ones[float64](dims)
    index = 0
  for i in orig.mitems:
    i = index.float64 / 3.0
    inc(index)

  var xTensor = jlArrayFromBuffer[float64](orig)

  block:
    var
      len_ret = len(xTensor)
      rank_ret = ndims(xTensor)
    check len_ret == orig.size
    check rank_ret == orig.rank

    var
      d0 = dim(xTensor, 0)
      d1 = dim(xTensor, 1)
      d2 = dim(xTensor, 2)
    check @[d0, d1, d2] == orig.shape.toSeq

  var
    ret = toJlArray[float64](jlCall("squareMeBaby", xTensor))
    len_ret = len(ret)
    rank_ret = ndims(ret)
  check len_ret == orig.size
  check rank_ret == 3

  var tensorData: Tensor[float64] = ret.to(Tensor[float])
  check tensorData == square(orig)

proc tensorMutateMeBaby() =
  let dims = [14, 12, 10]
  var
    orig: Tensor[float64] = ones[float64](dims)
    index = 0
  for i in orig.mitems:
    inc(index)
    i = index.float64 / 3.0

  # Create an immutable tensor for comparaison with original
  let tensorcmp = orig.clone()
  var
    ret = toJlArray[float64](jlCall("mutateMeByTen!", orig))
    len_ret = len(ret)
    rank_ret = ndims(ret)
  check not isNil(ret)
  check len_ret == orig.size
  check rank_ret == 3
  # Check result is correct
  check orig == tensorcmp.map(x => x*10)

proc tensorBuiltinRot180() =
  var
    orig_tensor = newTensor[float64](4, 3)
    index = 0
  for i in orig_tensor.mitems:
    i = index.float64
    inc(index)

  var
    xArray = jlArrayFromBuffer[float64](orig_tensor)
    d0 = dim(xArray, 0).int
    d1 = dim(xArray, 1).int

  check d0 == orig_tensor.shape[0]
  check d1 == orig_tensor.shape[1]

  var ret = toJlArray[float64](jlCall("rot180", xArray))
  check not isNil(ret)

  var tensorResData = ret.to(Tensor[float64])
  check tensorResData == (11.0 -. orig_tensor)

proc runTensorArgsTest*() =
  suite "Tensor":
    teardown: jlGcCollect()

    test "external_module : squareMeBaby[Tensor]":
      tensorSquareMeBaby()

    test "external_module : mutateMeByTen[Tensor]":
      tensorMutateMeBaby()

    test "external_module : rot180[Tensor]":
      tensorBuiltinRot180()

proc runExternalsTest*() =
  suite "external module":
    teardown: jlGcCollect()
    test "external_module":
      includeExternalModule()

    test "dummy":
      callDummyFunc()

proc runTests*() =
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()
  runSimpleTests()
  runTupleTest()
  run1DArrayTest()
  runArrayArgsTest()
  runTensorArgsTest()
  jlVmExit(0)

when isMainModule:
  runTests()

## Mem Leak Tests
import os
import times
import std/monotimes
proc runMemLeakTest*(maxDuration: Duration) =
  # Hello Julia
  jlVmInit()

  # run Externals include module so ran it first and only once
  runExternalsTest()

  let begin = getMonoTime()
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)
  let deltaTest = initDuration(seconds = 1)
  var maxDuration = maxDuration + 4*deltaTest

  while elapsed <= maxDuration:
    elapsed = getMonoTime() - begin
    runTupleTest()
    sleep(deltaTest.inMilliseconds().int)
    run1DArrayTest()
    sleep(deltaTest.inMilliseconds().int)
    runArrayArgsTest()
    sleep(deltaTest.inMilliseconds().int)
    runTensorArgsTest()
    sleep(deltaTest.inMilliseconds().int)

  # Bye bye Julia
  jlVmExit(0)
  echo GC_getStatistics()
  sleep(deltaTest.inMilliseconds().int)

