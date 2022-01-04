# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import ./types
import ./cores
import ./functions
import ./conversions

import ./private/jlcores

type Julia* = object

template Embed*(jl: type Julia, body: untyped) =
  JlEmbed(body)

proc embedFile*(jl: type Julia, fname: static[string]) =
  jlEmbedFile(fname)

proc embedDir*(jl: type Julia, dirname: static[string]) =
  jlEmbedDir(dirname)

proc init*(jl: type Julia) =
  jlVmInit()

template init*(jl: type Julia, body: untyped) =
  JlEmbed(body)
  jlVmInit()

proc exit*(jl: type Julia, exitcode: int = 0) =
  jlVmExit(exitcode.cint)

proc useModule*(jl: type Julia, modname: string) =
  jlUseModule(modname)

proc includeFile*(jl: type Julia, fname: string) =
  jlInclude(fname)

# macro loadModule*(jl: type Julia, modname: untyped) =
# TODO generate a proc ``modname`` that returns module

#####################################################
# Interop and utility
#####################################################
proc `$`*(val: JlValue): string =
  jlCall("string", val).to(string)

proc `$`*(val: JlModule): string =
  jlCall("string", val).to(string)

proc `$`*[T](val: JlArray[T]): string =
  jlCall("string", val).to(string)

proc `$`*(val: JlFunc): string =
  jlCall("string", val).to(string)

proc `$`*(val: JlSym): string =
  jlCall("string", val).to(string)

# typeof is taken by Nim already
proc jltypeof*(x: JlValue): JlValue =
  jlCall("typeof", x)

proc len*(val: JlValue): int =
  jlCall("length", val).to(int)

proc firstindex*(val: JlValue): int =
  jlCall("firstindex", val).to(int)

proc lastindex*(val: JlValue): int =
  jlCall("lastindex", val).to(int)

template getproperty*(val: JlValue, propertyname: string): JlValue =
  jlCall("getproperty", val, jlSym(propertyname))

template setproperty*(val: JlValue, propertyname: string, newval: untyped) =
  discard jlCall("setproperty!", val, jlSym(propertyname), newval)

#####################################################
# Syntactic sugar
#####################################################
import std/macros

{.experimental: "dotOperators".}

macro unpackVarargs_first(callee, arg_first: untyped; arg_second: untyped, args: varargs[untyped]):untyped =
  result = newCall(callee)
  result.add arg_first
  result.add arg_second
  for a in args:
    result.add a

template `.()`*(jl: type Julia, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  jlCall(astToStr(funcname), args)

template `.()`*(jlmod: JlModule, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  jlCall(jlmod, astToStr(funcname), args)

template `.()`*(jlval: JlValue, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  unpackVarargs_first(jlCall, astToStr(funcname), jlval, args)

template `.`*(jlval: JlValue, propertyname: untyped): JlValue =
  getproperty(jlval, astToStr(propertyname))

template `.=`*(jlval: var JlValue, fieldname: untyped, newval: untyped) =
  setproperty(jlval, astToStr(fieldname), newval)

# Re-export
import ./sugar/iterators
export iterators

import ./sugar/operators
export operators

import ./sugar/valindexing
export valindexing
