import ../types
import std/strformat

proc to*(t: JlDataType) : typedesc =
  case t
  of jlType(char):
    return typedesc[char]

  of jlType(int8):
    return typedesc[int8]
  of jlType(int16):
    return typedesc[int16]
  of jlType(int32):
    return typedesc[int32]
  of jlType(int64):
    return typedesc[int64]

  of jlType(uint8):
    return typedesc[uint8]
  of jlType(uint16):
    return typedesc[uint16]
  of jlType(uint32):
    return typedesc[uint32]
  of jlType(uint64):
    return typedesc[uint64]

  of jlType(float32):
    return typedesc[float32]
  of jlType(float64):
    return typedesc[float64]

  else:
    raise newException(JlError, &"Type conversion from Nim to Julia not support for type {T}")
