import basetypes
import config

## Box & Unbox
## Using box allocate memory managed by Julia's GC
proc nimjl_unbox_float64*(value: ptr nimjl_value): float64 {.cdecl, importc.}
proc nimjl_unbox_float32*(value: ptr nimjl_value): float32 {.cdecl, importc.}

proc nimjl_unbox_int64*(value: ptr nimjl_value): int64 {.cdecl, importc.}
proc nimjl_unbox_int32*(value: ptr nimjl_value): int32 {.cdecl, importc.}
proc nimjl_unbox_int16*(value: ptr nimjl_value): int16 {.cdecl, importc.}
proc nimjl_unbox_int8*(value: ptr nimjl_value): int8 {.cdecl, importc.}

proc nimjl_unbox_uint64*(value: ptr nimjl_value): uint64 {.cdecl, importc.}
proc nimjl_unbox_uint32*(value: ptr nimjl_value): uint32 {.cdecl, importc.}
proc nimjl_unbox_uint16*(value: ptr nimjl_value): uint16 {.cdecl, importc.}
proc nimjl_unbox_uint8*(value: ptr nimjl_value): uint8 {.cdecl, importc.}

proc nimjl_box_float64*(value: float64): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_float32*(value: float32): ptr nimjl_value {.cdecl, importc.}

proc nimjl_box_int64*(value: int64): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_int32*(value: int32): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_int16*(value: int16): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_int8*(value: int8): ptr nimjl_value {.cdecl, importc.}

proc nimjl_box_uint64*(value: uint64): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_uint32*(value: uint32): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_uint16*(value: uint16): ptr nimjl_value {.cdecl, importc.}
proc nimjl_box_uint8*(value: uint8): ptr nimjl_value {.cdecl, importc.}

proc nimjl_unbox*[T](value: ptr nimjl_value): T =
  when T is int8:
    result = nimjl_unbox_int8(value)
  elif T is int16:
    result = nimjl_unbox_int16(value)
  elif T is int32:
    result = nimjl_unbox_int32(value)
  elif T is int64:
    result = nimjl_unbox_int64(value)
  elif T is uint8:
    result = nimjl_unbox_uint8(value)
  elif T is uint16:
    result = nimjl_unbox_uint16(value)
  elif T is uint32:
    result = nimjl_unbox_uint32(value)
  elif T is uint64:
    result = nimjl_unbox_uint64(value)
  elif T is float32:
    result = nimjl_unbox_float32(value)
  elif T is float64:
    result = nimjl_unbox_float64(value)
  else:
    doAssert(false, "Type not supported")

proc nimjl_box*[T](value: T): ptr nimjl_value =
  when T is int8:
    result = nimjl_box_int8(value)
  elif T is int16:
    result = nimjl_box_int16(value)
  elif T is int32:
    result = nimjl_box_int32(value)
  elif T is int64:
    result = nimjl_box_int64(value)
  elif T is uint8:
    result = nimjl_box_uint8(value)
  elif T is uint16:
    result = nimjl_box_uint16(value)
  elif T is uint32:
    result = nimjl_box_uint32(value)
  elif T is uint64:
    result = nimjl_box_uint64(value)
  elif T is float32:
    result = nimjl_box_float32(value)
  elif T is float64:
    result = nimjl_box_float64(value)
  else:
    doAssert(false, "Type not supported")

