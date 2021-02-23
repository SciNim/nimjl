import ../config
import basetypes_helpers
import macros

## Box & Unbox
proc julia_unbox_float64*(value: ptr julia_value): float64 {.cdecl, importc.}
proc julia_unbox_float32*(value: ptr julia_value): float32 {.cdecl, importc.}

proc julia_unbox_int64*(value: ptr julia_value): int64 {.cdecl, importc.}
proc julia_unbox_int32*(value: ptr julia_value): int32 {.cdecl, importc.}
proc julia_unbox_int16*(value: ptr julia_value): int16 {.cdecl, importc.}
proc julia_unbox_int8*(value: ptr julia_value): int8 {.cdecl, importc.}

proc julia_unbox_uint64*(value: ptr julia_value): uint64 {.cdecl, importc.}
proc julia_unbox_uint32*(value: ptr julia_value): uint32 {.cdecl, importc.}
proc julia_unbox_uint16*(value: ptr julia_value): uint16 {.cdecl, importc.}
proc julia_unbox_uint8*(value: ptr julia_value): uint8 {.cdecl, importc.}

## Using box allocate memory managed by Julia's GC
proc julia_box_float64*(value: float64): ptr julia_value {.cdecl, importc.}
proc julia_box_float32*(value: float32): ptr julia_value {.cdecl, importc.}

proc julia_box_int64*(value: int64): ptr julia_value {.cdecl, importc.}
proc julia_box_int32*(value: int32): ptr julia_value {.cdecl, importc.}
proc julia_box_int16*(value: int16): ptr julia_value {.cdecl, importc.}
proc julia_box_int8*(value: int8): ptr julia_value {.cdecl, importc.}

proc julia_box_uint64*(value: uint64): ptr julia_value {.cdecl, importc.}
proc julia_box_uint32*(value: uint32): ptr julia_value {.cdecl, importc.}
proc julia_box_uint16*(value: uint16): ptr julia_value {.cdecl, importc.}
proc julia_box_uint8*(value: uint8): ptr julia_value {.cdecl, importc.}

# macro julia_unbox*(t: typedesc, value: ptr julia_value) : untyped =
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
#
