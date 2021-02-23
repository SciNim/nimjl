import basetypes
import config
import private/box


  # when T is int8:
  #   result = julia_unbox_int8(value)
  # elif T is int16:
  #   result = julia_unbox_int16(value)
  # elif T is int32:
  #   result = julia_unbox_int32(value)
  # elif T is int64:
  #   result = julia_unbox_int64(value)
  # elif T is uint8:
  #   result = julia_unbox_uint8(value)
  # elif T is uint16:
  #   result = julia_unbox_uint16(value)
  # elif T is uint32:
  #   result = julia_unbox_uint32(value)
  # elif T is uint64:
  #   result = julia_unbox_uint64(value)
  # elif T is float32:
  #   result = julia_unbox_float32(value)
  # elif T is float64:
  #   result = julia_unbox_float64(value)
  # else:
  #   doAssert(false, "Type not supported")

# proc julia_box*[T: SomeNumber](value: T): ptr julia_value =
  # when T is int8:
  #   result = julia_box_int8(value)
  # elif T is int16:
  #   result = julia_box_int16(value)
  # elif T is int32:
  #   result = julia_box_int32(value)
  # elif T is int64:
  #   result = julia_box_int64(value)
  # elif T is uint8:
  #   result = julia_box_uint8(value)
  # elif T is uint16:
  #   result = julia_box_uint16(value)
  # elif T is uint32:
  #   result = julia_box_uint32(value)
  # elif T is uint64:
  #   result = julia_box_uint64(value)
  # elif T is float32:
  #   result = julia_box_float32(value)
  # elif T is float64:
  #   result = julia_box_float64(value)
  # else:
  #   doAssert(false, "Type not supported")
  #

# macro julia_unbox*(t: typedesc, value: JlValue) : untyped =
#   let gentype = getTypeInst(t)[1]
#   let callStr = "julia_unbox_" & gentype.toStrLit().strVal
#   echo callStr
#   result = newCall(callStr, value)
#   echo result.repr
#
# macro julia_box*(t: typedesc, value: untyped): untyped =
#   let gentype = getTypeInst(t)[1]
#   let typeStr = gentype.toStrLit().strVal
#   let callStr = "julia_box_" & typeStr
#   result = newCall(callStr, value)

proc to*[T: SomeNumber](x: JlValue): T =
  result = julia_unbox(T, x)
  # result = julia_unbox_float64(x)

proc toJlValue*[T: SomeNumber](val: T): JlValue =
  result = julia_box(T, val)

# discard to[float64](jlEval("sqrt(1.0)"))
# discard to[float32](jlEval("sqrt(1.0)"))
# discard to[int8](jlEval("sqrt(1.0)"))
# discard to[uint8](jlEval("sqrt(1.0)"))
# discard toJlValue[float64](1.0'f64)
# discard toJlValue[float32](1.0'f32)
# discard toJlValue[int8](1'i8)
# discard toJlValue[uint8](1'u8)

