import ../config
import ./jlcores

## Box & Unbox
{.push nodecl, header: JuliaHeader, dynlib: JuliaLibName.}
proc jl_unbox_float64*(value: ptr jl_value): float64 {.importc.}
proc jl_unbox_float32*(value: ptr jl_value): float32 {.importc.}

proc jl_unbox_int64*(value: ptr jl_value): int64 {.importc.}
proc jl_unbox_int32*(value: ptr jl_value): int32 {.importc.}
proc jl_unbox_int16*(value: ptr jl_value): int16 {.importc.}
proc jl_unbox_int8*(value: ptr jl_value): int8 {.importc.}

proc jl_unbox_uint64*(value: ptr jl_value): uint64 {.importc.}
proc jl_unbox_uint32*(value: ptr jl_value): uint32 {.importc.}
proc jl_unbox_uint16*(value: ptr jl_value): uint16 {.importc.}
proc jl_unbox_uint8*(value: ptr jl_value): uint8 {.importc.}
proc jl_unbox_bool*(value: ptr jl_value): bool {.importc.}
proc jl_unbox_voidpointer*(value: ptr jl_value): pointer {.importc.}

## Using box allocate memory managed by Julia's GC
proc jl_box_voidpointer*(value: pointer): ptr jl_value {.importc.}
proc jl_box_bool*(value: bool): ptr jl_value {.importc.}
proc jl_box_float64*(value: float64): ptr jl_value {.importc.}
proc jl_box_float32*(value: float32): ptr jl_value {.importc.}

proc jl_box_int64*(value: int64): ptr jl_value {.importc.}
proc jl_box_int32*(value: int32): ptr jl_value {.importc.}
proc jl_box_int16*(value: int16): ptr jl_value {.importc.}
proc jl_box_int8*(value: int8): ptr jl_value {.importc.}

proc jl_box_uint64*(value: uint64): ptr jl_value {.importc.}
proc jl_box_uint32*(value: uint32): ptr jl_value {.importc.}
proc jl_box_uint16*(value: uint16): ptr jl_value {.importc.}
proc jl_box_uint8*(value: uint8): ptr jl_value {.importc.}
{.pop.}


