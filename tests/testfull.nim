import unittest
import sequtils
import sugar
import tables
import json

import arraymancer

import times
import std/monotimes
import ../nimjl

proc simpleEvalString() =
  var test = jlEval("sqrt(4.0)")
  check jlUnbox[float64](test) == 2.0

proc boxUnbox()=
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

proc jlCall()=
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
      jlCall()

###### ARRAY

proc jlArray1D()=
  let ARRAY_LEN = 10
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]

  var x : JlArray[float64]
  x = allocJlArray[float64]([ARRAY_LEN])
  julia_gc_push1(addr(x))
  var xData = dataArray[float64](x)
  check ARRAY_LEN == len(x)

  for i in 0..<len(x):
    xData[i] = i.float64

  var reverse = getJlFunc(jl_base_module, "reverse!")
  var res = jlCall(reverse, x.toJlValue())
  check not isNil(res)

  var resData = toJlArray[float64](res).dataArray()
  check resData == xData

  for i in 0..<ARRAY_LEN:
    check xData[i] == orig[ARRAY_LEN - i - 1]
  julia_gc_pop()

proc jlArray1DOwnBuffer() =
  let ARRAY_LEN = 10
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let unchecked_orig = cast[ptr UncheckedArray[float64]](orig[0].addr)

  # var array_type = nimjl_apply_array_type[float64](1)
  # var x = nimjl_ptr_to_array_1d(array_type, unchecked_orig, ARRAY_LEN.csize_t, 0)

  var x = newJlArray[float64](unchecked_orig, [10])
  check ARRAY_LEN == len(x)
  for i in 0..<len(x):
    unchecked_orig[i] = i.float64

  var reverse = getJlFunc(jl_base_module, "reverse!")
  var res = jlCall(reverse, x.toJlValue())
  check not isNil(res)

  var resData = toJlArray[float64](res).dataArray()
  check resData == unchecked_orig

  for i in 0..<ARRAY_LEN:
    check unchecked_orig[i] == (ARRAY_LEN - i - 1).float

proc runArrayTest()=

  suite "Array 1D":
    teardown: jlGcCollect()

    test "jl_array_1d":
      jlArray1D()

    test "jl_array_1d_own_buffer":
      jlArray1DOwnBuffer()

## Tuple stuff
proc makeTupleTest() =
  block:
    var jl_tuple = jlTuple((a:124, c: 67.32147))
    check not isNil(jl_tuple)
    julia_gc_push1(jl_tuple.addr)
    var ret = jlCall("tupleTest", jl_tuple)

    check not isNil(ret)
    if not isNil(ret):
      var bres = jlUnbox[uint8](ret)
      check bres == 255
    julia_gc_pop()

  type TT = object
    a: int
    c: float

  block:
    var tt: TT = TT(a: 124, c: 67.32147)
    var jl_tuple_fromobj = jlTuple(tt)
    check not isNil(jl_tuple_fromobj)
    julia_gc_push1(jl_tuple_fromobj.addr)

    var ret = jlCall("tupleTest", jl_tuple_fromobj)
    check not isNil(ret)
    if not isNil(ret):
      var bres = jlUnbox[uint8](ret)
      check bres == 255
    julia_gc_pop()

proc stringModTest() =
  var inputStr = "This is a nice string, isn't it ?"
  var res : string = jlUnbox[string](jlCall("modString", (jlBox(inputStr)))
  check inputStr & " This is an amazing string" == res

proc printDictTest() =
  block:
    var
      key1 = "t0acq"
      val1 = 14
      key2 = "xOrigin"
      val2 = 3.48
      dict : Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var res = jlCall("printDict", jlDict(%dict),
                     jlBox(key1),
                     jlBox(val1),
                     jlBox(key2),
                     jlBox(val2)
                    )
    check jlUnbox[bool](res)

  block:
    var
      key1 = "Nx"
      val1 = 144
      key2 = "dx"
      val2 = 100e-6
      dict : Table[string, float] = {key1: val1.float, key2: val2.float}.toTable
    var res = jlCall("printDict", jlDict(%dict),
                     jlBox(key1),
                     jlBox(val1),
                     jlBox(key2),
                     jlBox(val2)
                    )
    check jlUnbox[bool](res)


proc runTupleTest() =
  suite "Tuples":
    teardown: jlGcCollect()

    test "tupleTest":
      makeTupleTest()

    test "modString":
      stringModTest()

    test "dictTest":
      printDictTest()


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
  let orig_ptr = cast[ptr UncheckedArray[float64]](orig[0].addr)
  var xArray = newJlArray[float64](orig_ptr, @[orig.len])
  var ret = toJlArray[float64](jlCall("squareMeBaby", xArray.toJlValue()))

  var len_ret = len(ret)
  check len_ret == orig.len

  var rank_ret = ndims(ret)
  check rank_ret == 1

  var data_ret = dataArray(ret)
  for i in 0..<orig.len:
    check data_ret[i] == (i*i).float64

  var seqData: seq[float64] = newSeq[float64](len_ret)
  copyMem(seqData[0].unsafeAddr, data_ret, len_ret*sizeof(float64))
  check seqData == @[0.0, 1.0, 4.0, 9.0, 16.0, 25.0, 36.0, 49.0, 64.0, 81.0]

proc arrayMutateMeBaby() =
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]

  var data: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let data_ptr = cast[ptr UncheckedArray[float64]](data[0].addr)
  var xArray = newJlArray[float64](data_ptr, @[data.len])
  check not isNil(xArray.data)

  var ret = jlCall("mutateMeByTen!", xArray.toJlValue())
  check not isNil(ret)

  var len_ret = len(xArray)
  check len_ret == orig.len

  var rank_ret = ndims(xArray)
  check rank_ret == 1

  check data == @[0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0]
  check data == orig.map(x => x*10)

proc runArrayArgsTest() =
  suite "Array":
    teardown: jlGcCollect()

    test "external_module : squareMeBaby[Array]":
      arraySquareMeBaby()

    test "external_module : mutateMeByTen[Array]":
      arrayMutateMeBaby()

### Tensor Args
proc tensorSquareMeBaby() =
  var orig: Tensor[float64]
  orig = ones[float64](3, 4, 5)
  var index = 0
  for i in orig.mitems:
    i = index.float64 / 3.0
    inc(index)
  var xTensor = newJlArray[float64](orig.dataArray(), orig.shape.toSeq)
  block:
    var len_ret = len(xTensor)
    check len_ret == orig.size
    var rank_ret = ndims(xTensor)
    check rank_ret == orig.rank
    var d0 = dim(xTensor, 0)
    var d1 = dim(xTensor, 1)
    var d2 = dim(xTensor, 2)
    check @[d0, d1, d2] == orig.shape.toSeq

  var retVal = jlCall("squareMeBaby", xTensor.toJlValue())
  check not isNil(retVal)
  var ret = toJlArray[float64](retVal)
  var len_ret = len(ret)
  check len_ret == orig.size
  var rank_ret = ndims(ret)
  check rank_ret == 3
  var data_ret = dataArray(ret)
  var tensorData: Tensor[float64] = newTensor[float64](3, 4, 5)
  copyMem(tensorData.dataArray(), data_ret, len_ret*sizeof(float64))
  for i, v in enumerate(tensorData):
    check v == (i/3)*(i/3)

proc tensorMutateMeBaby() =
  var orig : Tensor[float64]
  orig = ones[float64](4, 6, 8)
  var index = 0
  for i in orig.mitems:
    inc(index)
    i = index.float64 / 3.0

  var xTensor = newJlArray[float64](orig.dataArray(), orig.shape.toSeq)
  var ret = toJlArray[float64](jlCall("mutateMeByTen!", xTensor.toJlValue()))
  check not isNil(ret.data)

  var len_ret = len(ret)
  check len_ret == orig.size
  var rank_ret = ndims(ret)
  check rank_ret == 3
  var data_ret = dataArray(ret)
  var tensorData: Tensor[float64] = newTensor[float64](4, 6, 8)
  copyMem(tensorData.dataArray(), data_ret, len_ret*sizeof(float64))
  check tensorData == orig

proc tensorBuiltinRot180() =
  var orig_tensor : Tensor[float64]
  orig_tensor = newTensor[float64](4, 3)
  var index = 0
  for i in orig_tensor.mitems:
    i = index.float64
    inc(index)

  var xArray = newJlArray[float64](orig_tensor.dataArray(), orig_tensor.shape.toSeq)

  var d0 = dim(xArray, 0).int
  var d1 = dim(xArray, 1).int
  check d0 == 4
  check d1 == 3

  var ret = toJlArray[float64](jlCall("rot180", xArray.toJlValue()))
  check not isNil(ret.data)

  var data_ret = dataArray(ret)
  var tensorResData = newTensor[float64](4, 3)
  copyMem(tensorResData.dataArray(), data_ret, orig_tensor.size*sizeof(float64))
  check tensorResData == (11.0 -. orig_tensor)

proc runTensorArgsTest() =
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

proc runMemLeakTest*() =
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()

  let begin = getMonoTime()
  let maxDuration = initDuration(seconds = 60'i64, nanoseconds = 0'i64)
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)

  while elapsed < maxDuration:
    elapsed = getMonoTime() - begin
    runSimpleTests()
    runTupleTest()
    runArrayTest()
    runArrayArgsTest()
    runTensorArgsTest()

  jlGcCollect()
  echo GC_getStatistics()

  jlVmExit(0)

proc runTests*() =
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()

  runSimpleTests()
  runTupleTest()
  runArrayTest()
  runArrayArgsTest()
  runTensorArgsTest()
  jlVmExit(0)

when isMainModule:
  runTests()
