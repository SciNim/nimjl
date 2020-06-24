import unittest
import nimjl
import arraymancer

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

test "jl_array_2d_own_buffer":
  let dims = @[6, 5]
  var orig : Tensor[float64] = newTensor[float64](30)
  for coord, x in orig.mpairs:
    x = coord[0].float

  let unchecked_orig = cast[ptr UncheckedArray[float64]](orig.data)

  var array_type : nimjl_value  = nimjl_apply_array_type_float64(1)
  var x = nimjl_ptr_to_array(array_type, unchecked_orig, ARRAY_LEN.csize_t, 0)

  check ARRAY_LEN == nimjl_array_len(x)

  for i in 0..<nimjl_array_len(x):
    unchecked_orig[i] = i.float64


  var reverse = nimjl_get_function("reverse!")
  var res = nimjl_call(reverse, x.addr, 1)
  var resData = cast[ptr UncheckedArray[float64]](nimjl_array_data(x))

  check resData == unchecked_orig

  for i in 0..<ARRAY_LEN:
    check unchecked_orig[i] == (ARRAY_LEN - i - 1).float



  #block:
  #  let ARRAY_LEN = 10
  #  var orig : seq[float64] = @[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  #  let unchecked_orig = cast[ptr UncheckedArray[float64]](orig[0].addr)
  #  var array_type : nimjl_value  = nimjl_apply_array_type_float64(2)
  #  var x = nimjl_alloc_array_2d(array_type, 10, 12)

  #  nimjl_gc_push1(x.addr)

  #  var xData = cast[ptr float64](nimjl_array_data(x))

  #  for i in 0..<nimjl_array_len(x):
  #    xData[i] = i.float64


  #  nimjl_gc_pop()



echo "exithook"
## atexit cause stack overflow ?
#nimjl_atexit_hook(0)


