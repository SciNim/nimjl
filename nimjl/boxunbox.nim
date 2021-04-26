import ./coretypes
import ./private/jlcores
import ./private/jlboxunbox

import std/tables
import std/json

{.push inline.}
## Unbox
proc julia_unbox(x: JlValue, T: typedesc[int8]): int8 = jl_unbox_int8(x)
proc julia_unbox(x: JlValue, T: typedesc[int16]): int16 = jl_unbox_int16(x)
proc julia_unbox(x: JlValue, T: typedesc[int32]): int32 = jl_unbox_int32(x)
proc julia_unbox(x: JlValue, T: typedesc[int64]): int64 = jl_unbox_int64(x)
proc julia_unbox(x: JlValue, T: typedesc[uint8]): uint8 = jl_unbox_uint8(x)
proc julia_unbox(x: JlValue, T: typedesc[uint16]): uint16 = jl_unbox_uint16(x)
proc julia_unbox(x: JlValue, T: typedesc[uint32]): uint32 = jl_unbox_uint32(x)
proc julia_unbox(x: JlValue, T: typedesc[uint64]): uint64 = jl_unbox_uint64(x)
proc julia_unbox(x: JlValue, T: typedesc[float32]): float32 = jl_unbox_float32(x)
proc julia_unbox(x: JlValue, T: typedesc[float64]): float64 = jl_unbox_float64(x)

proc julia_unbox(x: JlValue, T: typedesc[int]): int =
  when sizeof(int) == sizeof(int64):
    jl_unbox_int64(x).int
  else:
    jl_unbox_int32(x).int

proc julia_unbox(x: JlValue, T: typedesc[uint]): int =
  when sizeof(uint) == sizeof(uint64):
    jl_unbox_uint64(x).uint
  else:
    jl_unbox_uint32(x).uint

proc julia_unbox(x: JlValue, T: typedesc[bool]): bool = jl_unbox_bool(x)
proc julia_unbox(x: JlValue, T: typedesc[pointer]): pointer = jl_unbox_voidpointer(x)

## Box
proc julia_box(x: int8): JlValue = jl_box_int8(x)
proc julia_box(x: int16): JlValue = jl_box_int16(x)
proc julia_box(x: int32): JlValue = jl_box_int32(x)
proc julia_box(x: int64): JlValue = jl_box_int64(x)
proc julia_box(x: uint8): JlValue = jl_box_uint8(x)
proc julia_box(x: uint16): JlValue = jl_box_uint16(x)
proc julia_box(x: uint32): JlValue = jl_box_uint32(x)
proc julia_box(x: uint64): JlValue = jl_box_uint64(x)
proc julia_box(x: float32): JlValue = jl_box_float32(x)
proc julia_box(x: float64): JlValue = jl_box_float64(x)

proc julia_box(x: int): JlValue =
  when sizeof(int) == sizeof(int64):
    jl_box_int64(x)
  else:
    jl_box_int32(x)

proc julia_box(x: uint): JlValue =
  when sizeof(uint) == sizeof(uint64):
    jl_box_uint64(x)
  else:
    jl_box_uint32(x)

proc julia_box(x: bool): JlValue = jl_box_bool(x)
proc julia_box(x: pointer): JlValue = jl_box_voidpointer(x)

proc julia_unbox[T](x: JlValue, t: var T) =
  t = julia_unbox(x, typedesc(T))

{.pop.}

# API for box / unbox. Exported because it's part of Julia's API but it is recommendned to use converter API instead
proc jlUnbox*[T](x: JlValue): T =
  julia_unbox(x, result)

proc jlBox*[T](val: T): JlValue =
  julia_box(val)

