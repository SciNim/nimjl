# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import std/[os, strutils, strformat]
import ./types
import ./cores
import ./functions
import ./conversions

import ./private/jlcores

type Julia* = object

proc init*(jl: type Julia, nthreads: int = 1) =
  jlVmInit(nthreads)

# This should only be used to generate Expr() in order to use named argument in Pkg interface
proc fmtJlExpr(val: string) : string =
  result = ""
  if val[0] == ':' or val.startsWith("Expr") or val.startsWith("QuoteNode"):
    result.add(val)
  else:
    result.addQuoted(val)

proc jlExpr(head: string, vals: varargs[string]) : string =
  result = "Expr("
  result &= fmtJlExpr(head)

  for val in vals:
    if not val.isEmptyorWhitespace():
      result &= ", "
      result &= fmtJlExpr(val)
  result &= ")"

template init*(jl: type Julia, nthreads: int, body: untyped) =
  ## Init Julia VM
  var packages: seq[tuple[name, version: string]]
  template Pkg(innerbody: untyped) =
    ## Pkg installation API
    proc add(name: string, version: string = "") =
      packages.add((name: name, version: version, ))

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
    putEnv("JULIA_NUM_THREADS", $nthreads)
    jl_init()
    # Module installation
    Julia.useModule("Pkg")
    let Pkg = Julia.getModule("Pkg")
    for pkgspec in packages:
      let pkgversion = pkgspec.version
      let pkgname = pkgspec.name
      if isEmptyOrWhitespace(pkgversion):
        discard jlCall(Pkg, "add", pkgname)
      else:
        var strexpr = jlExpr(":call",
                       jlExpr(":.", ":Pkg", "QuoteNode(:add)"),
                       jlExpr(":kw", ":name", pkgname),
                       jlExpr(":kw", ":version", pkgversion)
        )
        var jlexpr = jlEval(strexpr)
        # Will crash if version are invalid
        discard jlTopLevelEval(jlexpr)

      # Julia.precompile()
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
