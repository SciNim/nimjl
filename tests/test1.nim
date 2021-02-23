import unittest
import nimjl

import arraymancer
import sequtils
# import macros
# import sugar

import times
import std/monotimes

proc simpleEvalString() =
  var test = jlEval("sqrt(4.0)")
  check to[float64](test) == 2.0

proc boxUnbox()=
  block:
    var orig: float64 = 126545836.31266
    var x = toJlValue[float64](orig)
    check to[float64](x) == orig

  block:
    var orig: float32 = 0.01561238536
    var x = toJlValue[float32](orig)
    check to[float32](x) == orig

  block:
    var orig: int8 = -121
    var x = toJlValue[int8](orig)
    check to[int8](x) == orig

  block:
    var orig: uint8 = 251
    var x = toJlValue[uint8](orig)
    check to[uint8](x) == orig

proc jlCall()=
  var x = toJlValue[float64](4.0)
  var f = getJlFunc(jl_base_module, "sqrt");
  var res = jlCall(f, x)
  check to[float64](res) == 2.0
  check to[float64](x) == 4.0

proc runSimpleTests() =
  suite "Basic stuff":
    teardown: julia_gc_collect()
    test "nim_eval_string":
      simpleEvalString()

    test "toJlValue_unbox":
      boxUnbox()

    test "jl_call1":
      jlCall()

###### ARRAY

proc jlArray1D()=
  let ARRAY_LEN = 10
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]

  var x = allocJlArray[float64]([ARRAY_LEN])
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

  var resData = res.toJlArray().dataArray()
  check resData == unchecked_orig

  for i in 0..<ARRAY_LEN:
    check unchecked_orig[i] == (ARRAY_LEN - i - 1).float

proc runArrayTest()=

  suite "Array 1D":
    teardown: julia_gc_collect()

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
      var bres = to[uint8](ret)
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
      var bres = to[uint8](ret)
      check bres == 255
    julia_gc_pop()

proc runTupleTest() =
  suite "Tuples":
    teardown: julia_gc_collect()
    test "tupleTest":
      makeTupleTest()

### Externals module & easy stuff
proc includeExternalModule() =
  jlInclude("tests/test.jl")
  jlUseModule(".custom_module")

proc callDummyFunc() =
  var ret = jlCall("dummy")
  check not isNil(ret)

proc runExternalsTest() =
  suite "external module":
    teardown: julia_gc_collect()
    test "external_module":
      includeExternalModule()

    test "dummy":
      callDummyFunc()

### Array args
proc arraySquareMeBaby() =
  var orig: seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let orig_ptr = cast[ptr UncheckedArray[float64]](orig[0].addr)
  var xArray = newJlArray(orig_ptr, @[orig.len])

  var ret = jlCall("squareMeBaby", xArray.toJlValue()).toJlArray()

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
  var xArray = newJlArray(data_ptr, @[data.len])
  check not isNil(xArray)

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
    teardown: julia_gc_collect()

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
  var xTensor = newJlArray[float64](orig)
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
  var ret = retVal.toJlArray()
  check not isNil(ret)
  var len_ret = len(ret)
  check len_ret == orig.size
  var rank_ret = rank(ret)
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

  var ret = jlCall("mutateMeByTen!", xTensor.toJlValue()).toJlArray()
  check not isNil(ret)

  var len_ret = len(ret)
  check len_ret == orig.size
  var rank_ret = rank(ret)
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

  var ret = jlCall("rot180", xArray.toJlValue()).toJlArray()
  check not isNil(ret)

  var data_ret = dataArray(ret)
  var tensorResData = newTensor[float64](4, 3)
  copyMem(tensorResData.dataArray(), data_ret, orig_tensor.size*sizeof(float64))
  check tensorResData == (11.0 -. orig_tensor)

proc runTensorArgsTest() =
  suite "Tensor":
    teardown: julia_gc_collect()

    test "external_module : squareMeBaby[Tensor]":
      tensorSquareMeBaby()

    test "external_module : mutateMeByTen[Tensor]":
      tensorMutateMeBaby()

    test "external_module : rot180[Tensor]":
      tensorBuiltinRot180()

proc runTests() =
  runSimpleTests()
  runTupleTest()
  runArrayArgsTest()
  runTensorArgsTest()

proc runMemLeakTest() =
  let begin = getMonoTime()
  let maxDuration = initDuration(seconds = 600'i64, nanoseconds = 0'i64)
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)

  while elapsed < maxDuration:
    elapsed = getMonoTime() - begin
    if elapsed.inSeconds mod 10 == 0:
      echo GC_getStatistics()
    runSimpleTests()
    runTupleTest()
    runArrayArgsTest()
    runTensorArgsTest()

  julia_gc_collect()
  echo GC_getStatistics()

when isMainModule:
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()

  runTests()
  # runMemLeakTest()

  jlVmExit(0)

