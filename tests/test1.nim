import unittest
import nimjl

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
  var f = nimjl_get_function("sqrt");
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


  var reverse = nimjl_get_function("reverse!")
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


  var reverse = nimjl_get_function("reverse!")
  var res = nimjl_call(reverse, x.addr, 1)
  var resData = cast[ptr UncheckedArray[float64]](nimjl_array_data(x))

  check resData == unchecked_orig

  for i in 0..<ARRAY_LEN:
    check unchecked_orig[i] == (ARRAY_LEN - i - 1).float

test "include test.jl":
  discard nimjl_eval_string("include(\"test.jl\")")
  #discard nimjl_eval_string("include(\"tests/test.jl\")")
  echo "0"
  var local_func = nimjl_get_function("AAA.testMeBaby")
  echo local_func.repr
  echo "1"
  var ret : nimjl_value = nimjl_eval_string("AAA.testMeBaby()")
  nimjl_gc_push1(ret.addr)

  var ex = nimjl_exception_occurred()
  echo nimjl_typeof_str(ex)
  echo ret.repr
  echo "2"
  var len_ret = nimjl_array_len(ret)
  echo len_ret
  echo "3"
  var rank_ret = nimjl_array_rank(ret)
  echo rank_ret
  echo "4"
  var data_ret : pointer = nimjl_array_data(ret)
  echo data_ret.repr
  echo "5"
  var retData = cast[ptr UncheckedArray[float64]](data_ret)
  echo "Result ?"
  for i in 0..<nimjl_array_len(ret):
    echo retData[i]

  nimjl_gc_pop()

echo "exithook"
## atexit cause stack overflow ?
#nimjl_atexit_hook(0)


