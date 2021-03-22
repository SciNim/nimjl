import basetypes
import strformat

## Check for nil result
proc jlInclude*(filename: string) =
  let tmp = jlEval(&"include(\"{file_name}\")")
  assert not tmp.isNil()

proc jlUseModule*(modname: string) =
  let tmp = jlEval(&"using {modname}")
  assert not tmp.isNil()

proc jlGetModule*(modname: string): JlModule =
  result = cast[JlModule](jlEval(modname))
