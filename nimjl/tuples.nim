import config
import basetypes
import strutils

# Tuple helpers -> result is memory managed by Julia's GC
proc nimjl_make_tuple*(v: tuple): ptr nimjl_value =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = nimjl_eval_string(tupleStr)

proc nimjl_make_tuple*(v: object): ptr nimjl_value =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = nimjl_eval_string(tupleStr)
