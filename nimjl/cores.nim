import ./types
import ./private/jlcores
import ./config
import std/[strformat, os, macros, tables]

# Convert a string to Julia Symbol
proc jlSym*(symname: string): JlSym =
  result = jl_symbol(symname.cstring)

proc jlExceptionHandler*() =
  let excpt: JlValue = jl_exception_occurred()
  if not isNil(excpt):
    let msg = $(jl_exception_message())
    raise newException(JlError, msg)
  else:
    discard

# Eval function that checkes error
proc jlEval*(code: string): JlValue =
  result = jl_eval_string(code)
  jlExceptionHandler()

# Include file or use module
# Check for nil result
proc jlInclude*(filename: string) =
  let tmp = jlEval(&"include(\"{filename}\")")
  if tmp.isNil:
    raise newException(JlError, "&Cannot include file {filename}")

proc jlUseModule*(modname: string) =
  let tmp = jlEval(&"using {modname}")
  if tmp.isNil:
    raise newException(JlError, "&Cannot use module {modname}")

# Just for convenience since Julia funciton is called using
proc jlUsing*(modname: string) =
  jlUseModule(modname)

# Import can be useful
proc jlImport*(modname: string) =
  let tmp = jlEval(&"import {modname}")
  if tmp.isNil:
    raise newException(JlError, "&Cannot import module {modname}")

proc jlGetModule*(modname: string): JlModule =
  let tmp = jlEval(modname)
  if tmp.isNil:
    raise newException(JlError, "&Cannot load module {modname}")
  result = cast[JlModule](tmp)

# JlNothing is handy to have
template JlNothing*(): JlValue = jlEval("nothing")

template JlCode*(body: string) =
  block:
    discard jleval(body)

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

#########################################
var staticContents: Table[string, string]

import std/logging

proc loadJlRessources*() =
  for key, content in staticContents.pairs():
    info("> Nimjl loading Julia ressource: ", key, ".jl")
    JlCode(content)

# Init & Exit function
proc jlVmInit*() =
  ## jlVmInit should only be called once per process
  ## Subsequent calls after the first one will be ignored
  if not jlVmIsInit():
    jl_init()
    loadJlRessources()
    return
  # raise newException(JlError, "jl_init() must be called once per process")

# Not exported for now because I don't know how it works
proc jlVmInit(pathToImage: string) {.used.} =
  ## Same as jlVmInit but with a pre-compiler image
  if not jlVmIsInit():
    let jlBinDir = cstring(JuliaPath / "bin")
    jl_init_with_image(jlBinDir, pathToImage.cstring)
    loadJlRessources()
    return

  # raise newException(JlError, "jl_init_with_image(...) must be called once per process")
proc private_addKeyVal*(key, value: string) =
  ## exported because macro doesn't work otherwise but shouldn't be used
  staticContents[key] = value

macro jlEmbedDir*(dirname: static[string]): untyped =
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
  const jlContent = staticRead(getProjectPath() / filename)
  staticContents[filename] = jlContent
