import unittest
import nimjl
import sequtils
import sugar

echo "init"
nimjl_init()

test "nim_eval_string":
  var test = nimjl_eval_string("sqrt(4.0)")
  check nimjl_unbox_float64(test) == 2.0

test "nimjl_box_unbox":
  block:
    var orig : float64 = 126545836.31266
    var x : nimjl_value = nimjl_box_float64(orig)
    check nimjl_unbox_float64(x) == orig

  block:
    var orig : float32 = 0.01561238536
    var x : nimjl_value = nimjl_box_float32(orig)
    check nimjl_unbox_float32(x) == orig

  block:
    var orig : int8 = -121
    var x : nimjl_value = nimjl_box_int8(orig)
    check nimjl_unbox_int8(x) == orig

  block:
    var orig : uint8 = 251
    var x : nimjl_value = nimjl_box_uint8(orig)
    check nimjl_unbox_uint8(x) == orig

test "jl_call1":
  var x : nimjl_value = nimjl_box_float64(4.0)
  var f = nimjl_get_function(jl_base_module, "sqrt");
  var res = nimjl_call1(f, x)
  check nimjl_unbox_float64(res) == 2.0
  check nimjl_unbox_float64(x) == 4.0

test "jl_array_1d":
  let ARRAY_LEN = 10
  var orig : seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let unchecked_orig = cast[ptr UncheckedArray[float64]](orig[0].addr)

  var array_type : nimjl_value  = nimjl_apply_array_type_float64(1)
  var x = nimjl_alloc_array_1d(array_type, ARRAY_LEN.csize_t)

  nimjl_gc_push1(x.addr)
  var xData : ptr UncheckedArray[float64] = cast[ptr UncheckedArray[float64]](nimjl_array_data(x))

  check ARRAY_LEN == nimjl_array_len(x)

  for i in 0..<nimjl_array_len(x):
    xData[i] = i.float64


  var reverse = nimjl_get_function(jl_base_module, "reverse!")
  var res = nimjl_call(reverse, x.addr, 1)
  var resData = cast[ptr UncheckedArray[float64]](nimjl_array_data(x))

  check resData == xData

  for i in 0..<ARRAY_LEN:
    check xData[i] == orig[ARRAY_LEN - i - 1]

  nimjl_gc_pop()

test "jl_array_1d_own_buffer":
  let ARRAY_LEN = 10
  var orig : seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let unchecked_orig = cast[ptr UncheckedArray[float64]](orig[0].addr)

  var array_type : nimjl_value  = nimjl_apply_array_type_float64(1)
  var x = nimjl_ptr_to_array_1d(array_type, unchecked_orig, ARRAY_LEN.csize_t, 1)

  check ARRAY_LEN == nimjl_array_len(x)

  for i in 0..<nimjl_array_len(x):
    unchecked_orig[i] = i.float64


  var reverse = nimjl_get_function(jl_base_module, "reverse!")
  var res = nimjl_call(reverse, x.addr, 1)
  var resData = cast[ptr UncheckedArray[float64]](nimjl_array_data(x))

  check resData == unchecked_orig

  for i in 0..<ARRAY_LEN:
    check unchecked_orig[i] == (ARRAY_LEN - i - 1).float

test "external_module":
  var res_eval_include = nimjl_eval_string("include(\"tests/test.jl\")")
  check not isNil(res_eval_include)
  var res_eval_using = nimjl_eval_string("using .custom_module")
  check not isNil(res_eval_using)

test "dummy":
  var dummy = nimjl_get_function(jl_main_module, "dummy")
  check not isNil(dummy)
  var ret : nimjl_value = nimjl_call0(dummy)
  check not isNil(ret)

test "external_module : testMeBaby":
  var testMeBaby = nimjl_get_function(jl_main_module, "testMeBaby")
  check not isNil(testMeBaby)

  var orig : seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let orig_ptr = cast[ptr UncheckedArray[float64]](orig[0].addr)
  var array_type : nimjl_value  = nimjl_apply_array_type_float64(1)
  var xArray = nimjl_ptr_to_array_1d(array_type, orig_ptr, orig.len.csize_t, 1)
  var ret : nimjl_value = nimjl_call1(testMeBaby, xArray)

  nimjl_gc_push1(ret)
  var len_ret = nimjl_array_len(ret)
  check len_ret == orig.len

  var rank_ret = nimjl_array_rank(ret)
  check rank_ret == 1

  var data_ret : nimjl_array = nimjl_array_data(ret)
  var seqData : seq[float64] = newSeq[float64](len_ret)
  copyMem(seqData[0].unsafeAddr, data_ret, len_ret*sizeof(float64))
  check seqData == @[0.0, 1.0, 4.0, 9.0, 16.0, 25.0, 36.0, 49.0, 64.0, 81.0]
 
  nimjl_gc_pop()

test "external_module : mutateMeBaby":
  var mutateMeBaby = nimjl_get_function(jl_main_module, "mutateMeBaby!")
  check not isNil(mutateMeBaby)

  var orig : seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let orig_ptr = cast[ptr UncheckedArray[float64]](orig[0].addr)
  var array_type : nimjl_value  = nimjl_apply_array_type_float64(1)
  var xArray= nimjl_ptr_to_array_1d(array_type, orig_ptr, orig.len.csize_t, 1)
  var ret : nimjl_value = nimjl_call1(mutateMeBaby, xArray)
  check not isNil(ret)

  var len_ret = nimjl_array_len(xArray)
  check len_ret == orig.len

  var rank_ret = nimjl_array_rank(xArray)
  check rank_ret == 1

  var data_ret : nimjl_array = nimjl_array_data(xArray)
  var seqData : seq[float64] = newSeq[float64](len_ret)
  copyMem(seqData[0].unsafeAddr, data_ret, len_ret*sizeof(float64))
  check seqData == @[111.11, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0]

echo "exithook"
nimjl_atexit_hook(0)
