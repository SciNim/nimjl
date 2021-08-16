import ../private/jlcores
import ../private/jlboxunbox

import ../types

{.push inline.}

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

{.pop.}

proc jlBox*[T](val: T): JlValue =
  julia_box(val)

