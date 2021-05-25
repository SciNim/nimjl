import ./config
import ./private/jlcores

type
  JlValue* = ptr jl_value
  JlModule* = ptr jl_module
  JlFunc* = ptr jl_func
  JlArray*[T] = ptr jl_array
  JlSym* = ptr jl_sym
  JlDataType* = ptr jl_datatype

type
  JlError* = object of IOError

{.push header: JuliaHeader.}
let
  JlMain*{.importc: "jl_main_module".}: JlModule
  JlCore*{.importc: "jl_core_module".}: JlModule
  JlBase*{.importc: "jl_base_module".}: JlModule
  JlTop*{.importc: "jl_top_module".}: JlModule

let
  JlBool*{.importc: "jl_bool_type".}: JlDataType
  JlChar*{.importc: "jl_char_type".}: JlDataType
  JlInt8*{.importc: "jl_int8_type".}: JlDataType
  JlInt16*{.importc: "jl_int16_type".}: JlDataType
  JlInt32*{.importc: "jl_int32_type".}: JlDataType
  JlInt64*{.importc: "jl_int64_type".}: JlDataType
  JlUint8*{.importc: "jl_uint8_type".}: JlDataType
  JlUint16*{.importc: "jl_uint16_type".}: JlDataType
  JlUint32*{.importc: "jl_uint32_type".}: JlDataType
  JlUint64*{.importc: "jl_uint64_type".}: JlDataType
  JlFloat32*{.importc: "jl_float32_type".}: JlDataType
  JlFloat64*{.importc: "jl_float64_type".}: JlDataType

# Currently, you need to define setControlCHook AFTER jlVmInit() or it won't take effect
# var jl_interrupt_exception{.importc: "jl_interrupt_exception".}: JlValue
{.pop.}

template jlType*(T: typedesc[int8]): JlDataType = JlInt8
template jlType*(T: typedesc[int16]): JlDataType = JlInt16
template jlType*(T: typedesc[int32]): JlDataType = JlInt32
template jlType*(T: typedesc[int64]): JlDataType = JlInt64

template jlType*(T: typedesc[uint8]): JlDataType = JlUint8
template jlType*(T: typedesc[uint16]): JlDataType = JlUint16
template jlType*(T: typedesc[uint32]): JlDataType = JlUint32
template jlType*(T: typedesc[uint64]): JlDataType = JlUint64

template jlType*(T: typedesc[int]): JlDataType =
  when sizeof(T) == sizeof(int64):
    jlType(int64)
  elif sizeof(T) == sizeof(int32):
    jlType(int32)
  else:
    {.error: "Unsupported sizeof(uint)".}

template jlType*(T: typedesc[uint]): JlDataType =
  when sizeof(T) == sizeof(uint64):
    jlType*(uint64)
  elif sizeof(T) == sizeof(uint32):
    jlType*(uint32)
  else:
    {.error: "Unsupported sizeof(uint)".}

template jlType*(T: typedesc[bool]): JlDataType = JlBool
template jlType*(T: typedesc[char]): JlDataType = JlChar
template jlType*(T: typedesc[float32]): JlDataType = JlFloat32
template jlType*(T: typedesc[float64]): JlDataType = JlFloat64
