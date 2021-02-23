import basetypes
import config
import private/box

proc jl_unbox[T: SomeNumber](value: JlValue): T =
  when T is int8:
    result = jl_unbox_int8(value)
  elif T is int16:
    result = jl_unbox_int16(value)
  elif T is int32:
    result = jl_unbox_int32(value)
  elif T is int64:
    result = jl_unbox_int64(value)
  elif T is uint8:
    result = jl_unbox_uint8(value)
  elif T is uint16:
    result = jl_unbox_uint16(value)
  elif T is uint32:
    result = jl_unbox_uint32(value)
  elif T is uint64:
    result = jl_unbox_uint64(value)
  elif T is float32:
    result = jl_unbox_float32(value)
  elif T is float64:
    result = jl_unbox_float64(value)
  else:
    doAssert(false, "Type not supported")

proc jl_box[T: SomeNumber](value: T): JlValue =
  when T is int8:
    result = jl_box_int8(value)
  elif T is int16:
    result = jl_box_int16(value)
  elif T is int32:
    result = jl_box_int32(value)
  elif T is int64:
    result = jl_box_int64(value)
  elif T is uint8:
    result = jl_box_uint8(value)
  elif T is uint16:
    result = jl_box_uint16(value)
  elif T is uint32:
    result = jl_box_uint32(value)
  elif T is uint64:
    result = jl_box_uint64(value)
  elif T is float32:
    result = jl_box_float32(value)
  elif T is float64:
    result = jl_box_float64(value)
  else:
    doAssert(false, "Type not supported")

proc to*[T: SomeNumber](x: JlValue): T =
  result = jl_unbox[T](x)

proc toJlValue*[T: SomeNumber](val: T): JlValue =
  result = jl_box[T](val)

