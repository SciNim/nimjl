# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import ./types
import ./cores
import ./functions

import ./sugar/converttypes
import ./private/jlcores

type Julia* = object

proc init*(jl: type Julia) =
  jlVmInit()

proc exit*(jl: type Julia, exitcode: int = 0) =
  jlVmExit(exitcode.cint)

template `.`*(jl: type Julia, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(astToStr(funcname), args)

template `.`*(jlmod: JlModule, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(jlmod, astToStr(funcname), args)

# typeof is taken by Nim already
proc jltypeof*(x: JlValue): JlValue =
  jlCall("typeof", x)

proc `$`*(val: JlValue) : string =
  jlCall("string", val).to(string)

proc `$`*(val: JlModule) : string =
  jlCall("string", val).to(string)

proc `$`*[T](val: JlArray[T]) : string =
  jlCall("string", val).to(string)

proc `$`*(val: JlFunc) : string =
  jlCall("string", val).to(string)

proc `$`*(val: JlSym) : string =
  jlCall("string", val).to(string)

# Julia operators
# Unary operator
proc `+`*(val: JlValue) : JlValue =
  Julia.`+`(val)
# Minus unary operator
proc `-`*(val: JlValue) : JlValue =
  Julia.`-`(val)

# Arithmetic
proc `+`*(val1, val2: JlValue) : JlValue =
  Julia.`+`(val1, val2)

proc `-`*(val1, val2: JlValue) : JlValue =
  Julia.`-`(val1, val2)

proc `*`*(val1, val2: JlValue) : JlValue =
  Julia.`*`(val1, val2)

proc `/`*(val1, val2: JlValue) : JlValue =
  Julia.`/`(val1, val2)

proc `%`*(val1, val2: JlValue) : JlValue =
  Julia.`%`(val1, val2)

# Boolean and / or
proc `and`*(val1, val2: JlValue) : JlValue =
  Julia.`&&`(val1, val2)

proc `or`*(val1, val2: JlValue) : JlValue =
  Julia.`||`(val1, val2)

# Bits && ||
proc bitand*(val1, val2: JlValue) : JlValue =
  Julia.`&`(val1, val2)

proc bitor*(val1, val2: JlValue) : JlValue =
  Julia.`|`(val1, val2)

proc equal*(val1, val2: JlValue) : bool =
  jlCall("==", val1, val2).to(bool)

# # Comparaison
template `==`*(val1, val2: JlValue) : bool =
  val1.equal(val2)

proc equal*[T](val1, val2: JlArray[T]) : bool =
  jlCall("==", val1, val2).to(bool)

# # Comparaison
template `==`*[T](val1, val2: JlArray[T]) : bool =
  val1.equal(val2)


proc `!=`*(val1, val2: JlValue) : bool =
  Julia.`!=`(val1, val2).to(bool)

proc `!==`*(val1, val2: JlValue) : bool =
  Julia.`!==`(val1, val2).to(bool)

# Assignment
# TODO
# +=, -=, /=, *=
#
# Dot operators
# TODO
# ., .*, ./, .+, .- etc..

proc len*(val: JlValue) : int =
  Julia.length(val).to(int)

proc firstindex*(val: JlValue) : int =
  Julia.firstindex(val).to(int)

proc lastindex*(val: JlValue) : int =
  Julia.lastindex(val).to(int)

template getindex*(val: JlValue, idx: varargs[untyped]) : JlValue =
  Julia.getindex(val, idx)

proc iterate*(val: JlValue) : JlValue  =
  result = JlMain.iterate(val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable value")

proc iterate*(val: JlValue, state: JlValue) : JlValue =
  result = JlMain.iterate(val, state)

iterator items*(val: JlValue) : JlValue =
  var it = iterate(val)
  while it != JlNothing:
    yield it.getindex(1)
    it = iterate(val, it.getindex(2))

iterator enumerate*(val: JlValue) : (int, JlValue) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it.getindex(1))
    it = iterate(val, it.getindex(2))
    inc(i)

