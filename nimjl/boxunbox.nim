import basetypes
import config
import private/boxunbox_helpers
import private/basetypes_helpers

proc julia_unbox[T](value: JlValue): T =
  when T is int8:
    result = jl_unbox_int8(value)
  elif T is int16:
    result = jl_unbox_int16(value)
  elif T is int32 or (T is int and sizeof(int) == sizeof(int32)):
    result = jl_unbox_int32(value)
  elif T is int64 or (T is int and sizeof(int) == sizeof(int64)):
    result = jl_unbox_int64(value)
  elif T is uint8:
    result = jl_unbox_uint8(value)
  elif T is uint16:
    result = jl_unbox_uint16(value)
  elif T is uint32 or (T is uint and sizeof(uint) == sizeof(uint32)):
    result = jl_unbox_uint32(value)
  elif T is uint64 or (T is uint and sizeof(uint) == sizeof(uint64)):
    result = jl_unbox_uint64(value)
  elif T is float32:
    result = jl_unbox_float32(value)
  elif T is float64:
    result = jl_unbox_float64(value)
  elif T is bool:
    result = jl_unbox_bool(value)
  elif T is pointer:
    result = jl_unbox_voidpointer(value)
  else:
    doAssert(false, "Type not supported")

proc julia_box[T](value: T): JlValue =
  when T is int8:
    result = jl_box_int8(value)
  elif T is int16:
    result = jl_box_int16(value)
  elif T is int32 or (T is int and sizeof(int) == sizeof(int32)):
    result = jl_box_int32(value)
  elif T is int64 or (T is int and sizeof(int) == sizeof(int64)):
    result = jl_box_int64(value)
  elif T is uint8:
    result = jl_box_uint8(value)
  elif T is uint16:
    result = jl_box_uint16(value)
  elif T is uint32 or (T is uint and sizeof(uint) == sizeof(uint32)):
    result = jl_box_uint32(value)
  elif T is uint64 or (T is uint and sizeof(uint) == sizeof(uint64)):
    result = jl_box_uint64(value)
  elif T is float32:
    result = jl_box_float32(value)
  elif T is float64:
    result = jl_box_float64(value)
  elif T is bool:
    result = jl_box_bool(value)
  elif T is pointer:
    result = jl_box_voidpointer(value)
  else:
    doAssert(false, "Type not supported")

template to*(x: JlValue, t: typedesc[SomeNumber|string|bool|pointer]): t =
  jlUnbox[t](x)

proc jlUnbox*[T: SomeNumber|string|bool|pointer](x: JlValue): T =
  when T is string:
    result = jlval_to_string(x)
  else:
    result = julia_unbox[T](x)

proc jlBox*[T: SomeNumber|string|bool|pointer](val: T): JlValue =
  when T is string:
    result = jlval_from_string(val)
  else:
    result = julia_box[T](val)

