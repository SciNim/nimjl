# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import ./types
import ./cores
import ./functions
import ./conversions

import ./private/jlcores

type Julia* = object

proc init*(jl: type Julia) =
  jlVmInit()

proc exit*(jl: type Julia, exitcode: int = 0) =
  jlVmExit(exitcode.cint)

# macro loadModule*(jl: type Julia, modname: untyped) =
# TODO generate a proc ``modname`` that returns module

template `.`*(jl: type Julia, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(astToStr(funcname), args)

template `.`*(jlmod: JlModule, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(jlmod, astToStr(funcname), args)

proc len*(val: JlValue): int =
  Julia.length(val).to(int)

proc firstindex*(val: JlValue): int =
  Julia.firstindex(val).to(int)

proc lastindex*(val: JlValue): int =
  Julia.lastindex(val).to(int)

template getindex*(val: JlValue, idx: varargs[untyped]): JlValue =
  Julia.getindex(val, idx)

proc iterate*(val: JlValue): JlValue =
  result = JlMain.iterate(val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable value")

proc iterate*(val: JlValue, state: JlValue): JlValue =
  result = JlMain.iterate(val, state)

iterator items*(val: JlValue): JlValue =
  var it = iterate(val)
  while it != JlNothing:
    yield it.getindex(1)
    it = iterate(val, it.getindex(2))

iterator enumerate*(val: JlValue): (int, JlValue) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it.getindex(1))
    it = iterate(val, it.getindex(2))
    inc(i)

import ./sugar/operators
export operators

import ./sugar/valindexing
export valindexing
