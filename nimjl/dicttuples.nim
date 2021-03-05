import config
import basetypes
import functions

import strutils
import tables
import npeg

# Tuple helpers -> result is memory managed by Julia's GC
proc nimTupleToJlTuple*(v: tuple): JlValue =
  result = jlEval("NamedTuple()")
  for name, field in v.fieldPairs:
    result = jlCall(jlBaseModule, "setindex", result, field, jlSym(name))


proc jlDictToNim*[U, V: string|SomeNumber|bool](val: JlValue, tab: var Table[U, V]) =
  discard
#   discard jlEval("""
# function printKeys(x)
#   ke = keys(x)
#   return sprint(show, ke)
# end
# export printkeys""")
#
  # var keys = jlCall("keys", val)
  # var show = getJlFunc("show")
  # echo "##################"
  # var dictstr = jlCall("sprint", show, val).jlValToString()
  # dictStr = dictStr.replace("=>", "=")
  # dictStr = dictStr[(dictStr.find("(")+1)..<dictStr.find(")")]
  # echo dictstr
  #
  # let parser = peg "pairs":
  #   pairs <- pair * *(',' * pair) * !1
  #   word <- +Alnum
  #   number <- +Alnum
  #   pair <- word * '=' * number
  #
  # let r = parser.match(dictstr)
  # echo r
  #
  # parser.match(dictstr, tab)

  # echo "##################"
  # var values = jlCall("values", val)

proc nimTableToJlDict*[U, V: string|SomeNumber](tab: Table[U, V]): JlValue =
  result = jlEval("Dict()")
  for name, field in tab:
    discard jlCall(jlBaseModule, "setindex!", result, field, name)

# proc nimJsonToJlDict*(json: JsonNode): JlValue =
#   result = jlEval("Dict()")
#   for name, field in json:
#     case field.kind
#     of JBool:
#       discard jlCall(jlBaseModule, "setindex!", result, jlBox[bool](field.bval), name)
#     of JInt:
#       discard jlCall(jlBaseModule, "setindex!", result, jlBox(field.num), name)
#     of JFloat:
#       discard jlCall(jlBaseModule, "setindex!", result, jlBox(field.fnum), name)
#     of JString:
#       discard jlCall(jlBaseModule, "setindex!", result, nimStringToJlVal(field.str), name)
#     of JNull:
#       discard
#     of JArray:
#       # TODO SUpport array of JsonNode
#       # discard jlCall(jlBaseModule, "setindex!", result, field, name)
#       discard
#     of JObject:
#       discard jlCall(jlBaseModule, "setindex!", result, nimJsonToJlDict(field), name)

