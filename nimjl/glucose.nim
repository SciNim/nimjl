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
proc jltypeof*(jl: type Julia, x: JlValue): JlValue =
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

let Iterators* = jlGetModule("Iterators")
iterator items*(val: JlValue) : JlValue =
  var it = Iterators.Stateful(val)
  while not JlBase.done(it).to(bool):
    yield JlBase.next(it)

export converttypes

