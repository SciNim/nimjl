import unittest
import nimjl

echo "init"
nimjl_init()

block:
  echo "eval_string"
  discard nimjl_eval_string("print(sqrt(2.0))")
  var test = nimjl_eval_string("sqrt(4.0)")
  echo nimjl_unbox_float64(test)

block:
  echo "jl_call"
  var x : nimjl_value = nimjl_box_float64(4.0)
  var f = nimjl_get_function("sqrt");
  var res = nimjl_call(f, x.addr, 1.cint)
  echo nimjl_unbox_int32(res)
  echo nimjl_unbox_float64(x)

echo "exithook"
## atexit cause stack overflow ?
#nimjl_atexit_hook(0)


