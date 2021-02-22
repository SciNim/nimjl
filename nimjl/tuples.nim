import config
import basetypes
import strutils

# Tuple helpers -> result is memory managed by Julia's GC
proc jlTuple*(v: tuple): JlValue =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = jlEval(tupleStr)

proc jlTuple*(v: object): JlValue =
  var tupleStr = $v
  tupleStr = tupleStr.replace(":", "=")
  # This make tuple of a single element valid
  # (1) won't create a valid tuple -> (1,) is a valid tuple
  tupleStr = tupleStr.replace(")", ",)")
  result = jlEval(tupleStr)
