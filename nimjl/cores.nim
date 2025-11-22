import ./types
import ./errors  # Import new error handling
import ./private/jlcores
import ./config
import std/[strformat, os, macros, tables]

export errors  # Export error handling utilities

proc jlSym*(symname: string): JlSym =
  ## Convert a string to Julia Symbol
  checkJlInitialized("creating Julia symbol")
  result = jl_symbol(symname.cstring)

proc jlExceptionHandler*() =
  ## Deprecated: Use enhancedJlExceptionHandler instead
  enhancedJlExceptionHandler()

proc jlEval*(code: string): JlValue =
  ## Eval function that checks Julia errors with context
  checkJlInitialized("evaluating Julia code")
  result = jl_eval_string(code)
  enhancedJlExceptionHandler(&"evaluating: {code}")

proc jlTopLevelEval*(x: JlValue) : JlValue =
  ## Only use it if you know what you're doing
  checkJlInitialized("top-level eval")
  if x.isNil:
    raise newException(JlNullPointerError, "Cannot evaluate nil JlValue")
  result = jl_toplevel_eval(JlMain, x)
  enhancedJlExceptionHandler("top-level eval")

proc jlInclude*(filename: string) =
  ## Include Julia file with improved error handling
  checkJlInitialized(&"including file '{filename}'")
  if not fileExists(filename):
    raise newException(JlError, &"File not found: {filename}")
  let tmp = jlEval(&"include(\"{filename}\")")
  if tmp.isNil:
    raise newException(JlError, &"Failed to include file: {filename}")

proc jlUseModule*(modname: string) =
  ## Call using module with improved error handling
  checkJlInitialized(&"loading module '{modname}'")
  let tmp = jlEval(&"using {modname}")
  if tmp.isNil:
    raise newException(JlError, &"Failed to load module: {modname}")

proc jlUsing*(modname: string) =
  ## Alias for conveniece
  jlUseModule(modname)

proc jlImport*(modname: string) =
  ## Import Julia file
  let tmp = jlEval(&"import {modname}")
  if tmp.isNil:
    raise newException(JlError, "&Cannot import module {modname}")

proc jlGetModule*(modname: string): JlModule =
  ## Get Julia module. Useful to resolve ambiguity
  checkJlInitialized(&"getting module '{modname}'")
  let tmp = jlEval(modname)
  if tmp.isNil:
    raise newException(JlError, &"Cannot load module: {modname}")
  result = cast[JlModule](tmp)

# JlNothing is handy to have
template JlNothing*(): JlValue = jlEval("nothing")

template JlCode*(body: string) =
  block:
    discard jlEval(body)

proc jlVmIsInit*(): bool =
  bool(jl_is_initialized())

proc jlVmSaveImage*(fname: string) =
  jl_save_system_image(fname.cstring)

proc jlVmExit*(exit_code: cint = 0.cint) =
  ## jlVmExit should only be called once per process
  ## Subsequent calls after the first one will be ignored
  once:
    jl_atexit_hook(exit_code)
    return
  # Do nothing -> atexit_hook must be called once
 # raise newException(JlError, "jl_atexit_hook() must be called once per process")

# proc jlVmSaveExit*(fpath: string) =
#   discard jlEval(fmt"exit_save_sysimage({fpath})")

#########################################
var staticContents: OrderedTable[string, string]

import std/logging

proc getStaticContents*(): OrderedTable[string, string] =
  ## Get the compile-time embedded Julia files
  ## Used by system image creation to include embedded code
  result = staticContents

proc loadJlRessources*() =
  for key, content in staticContents.pairs():
    info("> Nimjl loading Julia ressource: ", key)
    # debugEcho("> Nimjl loading Julia ressource: ", key)
    JlCode(content)

# Init & Exit function
proc jlVmInit*() =
  ## jlVmInit should only be called once per process
  ## Subsequent calls after the first one will be ignored
  if not jlVmIsInit():
    jl_init()
    # loadJlRessources()
    return
  # raise newException(JlError, "jl_init() must be called once per process")

# proc jlVmInitWithImg*(fpath: string) =
#   jl_init_with_image(JuliaBinDir.cstring, fpath.cstring)

proc jlVmInit*(nthreads: int) =
  putEnv("JULIA_NUM_THREADS", $nthreads)
  jlVmInit()

# Not exported for now because I don't know how it works
proc jlVmInit(pathToImage: string) {.used.} =
  ## Same as jlVmInit but with a pre-compiler image
  if not jlVmIsInit():
    let jlBinDir = cstring(JuliaPath / "bin")
    jl_init_with_image(jlBinDir, pathToImage.cstring)
    # loadJlRessources()
    return

  # raise newException(JlError, "jl_init_with_image(...) must be called once per process")
proc private_addKeyVal*(key, value: string) =
  ## exported because macro doesn't work otherwise but shouldn't be used
  staticContents[key] = value

macro jlEmbedDir*(dirname: static[string]): untyped =
  ## Embed all Julia files from specified directory
  result = newStmtList()
  let path = getProjectPath() / dirname
  # echo path
  # echo "------------------------------------------"

  for file in path.walkDir:
    if file.kind == pcFile:
      let (dir, name, ext) = file.path.splitFile
      if ext == ".jl":
        # echo ">> ", name
        let content = readFile(file.path)
        result.add newCall("private_addKeyVal", newStrLitNode(name), newStrLitNode(content))

  # echo "------------------------------------------"
  # echo result.repr

proc jlEmbedFile*(filename: static[string]) =
  ## Embed specific Julia file
  const jlContent = staticRead(getProjectPath() / filename)
  staticContents[filename] = jlContent
