# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import std/[os, strutils, strformat, tables, paths]
import ./types
import ./cores
import ./functions
import ./conversions

import ./private/jlcores

type Julia* = object

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


proc init*(jl: type Julia, nthreads: int = 1) =
  jlVmInit(nthreads)

# This should only be used to generate Expr() in order to use named argument in Pkg interface
proc fmtJlExpr(val: string): string =
  result = ""
  if val[0] == ':' or val.startsWith("Expr") or val.startsWith("QuoteNode"):
    result.add(val)
  else:
    result.addQuoted(val)

proc jlExpr(head: string, vals: varargs[string]): string =
  result = "Expr("
  result &= fmtJlExpr(head)

  for val in vals:
    if not val.isEmptyorWhitespace():
      result &= ", "
      result &= fmtJlExpr(val)
  result &= ")"

type
  JlPkgSpec = object
    name, url, path, subdir, rev, version, mode, level: string
  JlPkgs = seq[JlPkgSpec]

proc checkJlPkgSpec(installed: Table[string, string], package: JlPkgSpec) : bool =
  # Check if package is installed with the correct version

  result = false
  if installed.contains(package.name):
    let installedVer = installed[package.name]
    var verCheck = ""
    if installedVer != "nothing":
      # Split + symbol for some reason Julia.Pkg sometimes use it even if it's outside of semver
      verCheck = installedVer.split('+')[0]

    if package.version.isEmptyOrWhitespace():
      # If no Pkg version is specified, package presence is enough
      result = true
    else:
      # Else result is true if semver matches
      result = (verCheck == package.version)

# Workaround because named parameters do not work inside closure for proc defined in template
# TODO : Should string be static ?
proc addImpl(pkgs: var JlPkgs, name: static string, url: static string = "", path: static string = "", subdir: static string = "", rev: static string = "", version: static string = "", mode: static string = "", level: static string = "") =
  if not jlVmIsInit():
    pkgs.add(JlPkgSpec(name: name, url: url, path: path, subdir: subdir, rev: rev, version: version, mode: mode, level: level))

template add*(name: static string, url: static string = "", path: static string = "", subdir: static string = "", rev: static string = "", version: static string = "", mode: static string = "", level: static string = "") =
  ## Nim native way of calling Julia Pkg.add during Julia.init()
  ##
  ## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
  ## Pkg.add("Example") # Add a package from registry
  ## Pkg.add("Example"; preserve=Pkg.PRESERVE_ALL) # Add the `Example` package and preserve existing dependencies
  ## Pkg.add(name="Example", version="0.3") # Specify version; latest release in the 0.3 series
  ## Pkg.add(name="Example", version="0.3.1") # Specify version; exact release
  ## Pkg.add(url="https://github.com/JuliaLang/Example.jl", rev="master") # From url to remote gitrepo
  ## Pkg.add(url="/remote/mycompany/juliapackages/OurPackage") # From path to local gitrepo
  ## Pkg.add(url="https://github.com/Company/MonoRepo", subdir="juliapkgs/Package.jl)") # With subdir
  when declared(jl_pkg_private_scope):
    addImpl(jl_pkg_private_scope, name, url, path, subdir, rev, version, mode, level)
  else:
    {.error: "Pkg: add() can only be called during Julia.init() scope"}

template init*(jl: type Julia, nthreads: int, body: untyped) =
  ## Init Julia VM
  var packages: JlPkgs
  var pkgEnv {.inject.} : string = ""

  template Pkg(innerbody: untyped) {.used.} =
    block:
      # Technically accessible but since the type are not exported, what are you going to do with it ?
      # It's good enough : the API is simple and close to Julia native for people not to get confused
      var jl_pkg_private_scope {.inject.}: JlPkgs
      innerbody
      packages = jl_pkg_private_scope

  template activate(env: string) {.used.} =
    ## Activate a Julia virtual env
    pkgEnv = string(expandTilde(Path(env)))

  template Embed(innerbody: untyped) {.used.} =
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
    jlInitialized = jl_is_initialized().bool  # Verify initialization succeeded
    # Module installation
    Julia.useModule("Pkg")
  else:
    raise newException(JlError, "Error Julia.init() has already been initialized")

  if not pkgEnv.isEmptyOrWhitespace():
    debugEcho(&"\"Pkg.activate(\"{pkgEnv}\")\"")
    discard jlEval(&"Pkg.activate(\"{pkgEnv}\")")

  when compiles(postJlInit()):
    postJlInit()

  let
    jlExistingPkgStr = "Dict(x[2].name => string(x[2].version) for x in Pkg.dependencies())"
    jlPkgsExisting = jlEval(jlExistingPkgStr)
    installed = jlPkgsExisting.to(Table[string, string])

  for pkgspec in packages:
    if not checkJlPkgSpec(installed, pkgspec):
      var exprs: seq[string] = @[jlExpr(":.", ":Pkg", "QuoteNode(:add)")]
      for key, field in pkgspec.fieldPairs():
        let fname =  ":" & key
        if not isEmptyOrWhitespace(field):
          exprs.add jlExpr(":kw", fname, field)

      let strexpr = jlExpr(":call", exprs)
      var jlexpr = jlEval(strexpr)
      # Will crash if version are invalid
      discard jlTopLevelEval(jlexpr)

  for pkgspec in packages:
    # TODO : handle precompilation ?
    # Julia.precompile()
    jlUsing(pkgspec.name)

  # Eval Julia code embedded
  loadJlRessources()

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
