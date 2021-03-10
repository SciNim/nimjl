import config
import basetypes
import functions

import tables
import strutils

# Tuple helpers -> result is memory managed by Julia's GC
# Convert object as tuple ?
proc nimToJlTuple*(v: tuple|object): JlValue =
  result = jlEval("NamedTuple()")
  for name, field in v.fieldPairs:
    result = jlCall(jlBaseModule, "setindex", result, field, jlSym(name))

proc jlTupleToNim*(val: JlValue, tup: var tuple) =
  # collect(keys(val))
  var keys = jlCall("keys", val)
  keys = jlCall("collect", keys)
  # Tuple of JlSymbol
  # length(collect(keys(val)))
  var show = getJlFunc("show")
  var sprint = getJlFunc("sprint")
  var nkeys = jlCall("length", keys).to(int)
  var i = 0
  for name, field in tup.fieldPairs:
    inc(i)
    if i > nkeys:
      raise newException(JlError, "Tuple conversion from Julia to Nim failed ! Fields must identical")

    var
      key = jlCall("getindex", keys, i)
      keyName = jlCall(sprint, show, key).to(string)

    removePrefix(keyName, ':')
    if keyName == name:
      var val = jlCall("getindex", val, key)
      field = val.to(typedesc(field))
    else:
      raise newException(JlError, "Tuple conversion from Julia to Nim failed ! Fields must identical")

proc jlDictToNim*[U, V: string|SomeNumber|bool](val: JlValue, tab: var Table[U, V]) =
  # collect(keys(val))
  var keys = jlCall("keys", val)
  keys = jlCall("collect", keys)
  # Tuple of JlSymbol
  # length(collect(keys(val)))
  var nkeys = jlCall("length", keys).to(int)
  for i in 1..nkeys:
    var key = jlCall("getindex", keys, i)
    var val = jlCall("getindex", val, key)
    tab[key.to(U)] = val.to(V)


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

