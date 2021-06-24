import ../types
import ../functions
import ../cores
import ../private/jlcores

import ./unbox
import ./dict_tuples

import std/strformat

proc isdefined*(typename: string): bool =
  let cmdStr = &"@isdefined({typename})"
  let res = jlEval(cmdStr)
  result = jlUnbox[bool](res)

proc isstructtype*(typename: string): bool =
  let cmdStr = &"isstructtype({typename})"
  let res = jlEval(cmdStr)
  result = jlUnbox[bool](res)

# Make the template varargs converter happy... IF using hasproperty
# It seems to fail on its own if not ? Maybe that's enough
# proc toJlVal(x: JlValue) : JlValue = x
# proc toJlVal(x: JlSym) : JlValue = cast[JlValue](x)
# proc hasproperty*(obj: JlValue, symname: string): bool =
#   let res = jlCall("hasproperty", obj, jlSym(symname))
#   result = jlUnbox[bool](res)

proc nimToJlVal*[T: object](obj: T) : JlValue =
  var typename = $(typedesc[T])
  if isdefined(typename) and isstructtype(typename):

    result = jlEval(&"{typename}()")
    for name, field in obj.fieldPairs:
      discard jlCall("setproperty!", result, jlSym(name), field)
  else:
    # Return a named tuple if an equivalent type do not exsits
    result = nimToNamedJlTuple(obj)

proc assignproperty[T](val: JlValue, fieldvalue: var T) =
  fieldvalue = val.to(T)

proc jlStructToNim*(val: JlValue, obj: var object) =
  for name, field in obj.fieldPairs:
    let newval = jlCall("getproperty", val, jlSym(name))
    assignproperty(field, newval)

