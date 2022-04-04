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

template init*(jl: type Julia, body: untyped) =
  ## Init Julia VM
  var packages: seq[string]
  template Pkg(innerbody: untyped) =
    ## Pkg installation API
    proc add(pkgname: string) =
      packages.add pkgname
    innerbody

  template Embed(innerbody: untyped) =
    ## Emded Julia file explicitly of from a directory
    template file(filename: static[string]) =
      ## Embed file
      jlEmbedFile(filename)

    template dir(dirname: static[string]) =
      ## Embed directory
      jlEmbedDir(dirname)

    template thisDir() =
      ## Embed current dir
      jlEmbedDir("")

    block:
      innerbody

  body

  # Don't do anything if Julia is already initialized
  if not jlVmIsInit():
    jl_init()
    # Module installation
    Julia.useModule("Pkg")
    let pkg = Julia.getModule("Pkg")
    for pkgname in packages:
      discard jlCall(pkg, "add", pkgname)
      jlUsing(pkgname)

    # Eval Julia code embedded
    loadJlRessources()

  else:
    raise newException(JlError, "Error Julia.init() has already been initialized")

proc exit*(jl: type Julia, exitcode: int = 0) =
  ## Exit Julia VM
  jlVmExit(exitcode.cint)

proc useModule*(jl: type Julia, modname: string) =
  ## Alias for jlUseModule. "using" is a keyword in Nim and so wasn't available
  jlUseModule(modname)

proc getModule*(jl: type Julia, modname: string): JlModule =
  ## Alias for jlGetModule
  jlGetModule(modname)

proc includeFile*(jl: type Julia, fname: string) =
  ## Alias for jlInclude
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
  ## Call the Julia function typeof
  jlCall("typeof", x)

proc len*(val: JlValue): int =
  ##Call length
  jlCall("length", val).to(int)

proc firstindex*(val: JlValue): int =
  ## Call firstindex
  jlCall("firstindex", val).to(int)

proc lastindex*(val: JlValue): int =
  ## Call lastindex
  jlCall("lastindex", val).to(int)

template getproperty*(val: JlValue, propertyname: string): JlValue =
  ## Call getproperty
  jlCall("getproperty", val, jlSym(propertyname))

template setproperty*(val: JlValue, propertyname: string, newval: untyped) =
  ## Call setproperty
  discard jlCall("setproperty!", val, jlSym(propertyname), newval)

#####################################################
# Syntactic sugar
#####################################################
import std/macros

{.experimental: "dotOperators".}

macro unpackVarargs_first(callee, arg_first: untyped; arg_second: untyped, args: varargs[untyped]): untyped =
  result = newCall(callee)
  result.add arg_first
  result.add arg_second
  for a in args:
    result.add a

template `.()`*(jl: type Julia, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  ## Alias to call a Julia function
  jlCall(astToStr(funcname), args)

template `.()`*(jlmod: JlModule, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  ## Alias to call a Julia function
  jlCall(jlmod, astToStr(funcname), args)

template `.()`*(jlval: JlValue, funcname: untyped, args: varargs[JlValue, toJlVal]): JlValue =
  ## Alias to call a Julia function
  unpackVarargs_first(jlCall, astToStr(funcname), jlval, args)

template `.`*(jlval: JlValue, propertyname: untyped): JlValue =
  ## Alias for getproperty
  getproperty(jlval, astToStr(propertyname))

template `.=`*(jlval: var JlValue, fieldname: untyped, newval: untyped) =
  ## Alias for setproperty
  setproperty(jlval, astToStr(fieldname), newval)

# Re-export
import ./sugar/iterators
export iterators

import ./sugar/operators
export operators

import ./sugar/valindexing
export valindexing
