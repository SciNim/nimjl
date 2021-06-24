import ../private/jlcores
import ../private/jlboxunbox

import ../types

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

{.pop.}

proc julia_unbox[T](x: JlValue, t: var T) =
  t = julia_unbox(x, typedesc(T))

# API for box / unbox. Exported because it's part of Julia's API but it is recommendned to use converter API instead
proc jlUnbox*[T](x: JlValue): T =
  julia_unbox(x, result)


