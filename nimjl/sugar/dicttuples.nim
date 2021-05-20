import ../cores
import ../types
import ../functions

import std/tables
import std/strutils
import std/strformat

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

# Recursive import strategy
import ./converttypes
# Tuple helpers -> result is memory managed by Julia's GC
# Convert object as tuple ?
proc nimToUnnamedJlTuple*(v: tuple): JlValue =
  var tupStr = $v
  result = jlEval(tupStr)

proc nimToNamedJlTuple*(v: tuple|object): JlValue =
  result = jlEval("NamedTuple()")
  for name, field in v.fieldPairs:
    result = jlCall(JlBase, "setindex", result, toJlVal(field), jlSym(name))

proc isNamedTuple(v: tuple) : bool =
  var i = 1
  for name, field in v.fieldPairs:
    if name != &"Field{i}":
      return false
  return true

proc nimToJlTuple*(v: tuple): JlValue =
  if isNamedTuple(v):
    nimToNamedJlTuple(v)
  else:
    nimToUnnamedJlTuple(v)

proc nimToJlTuple*(v: object): JlValue =
  nimToNamedJlTuple(v)

proc nimTableToJlDict*[U, V: string|SomeNumber](tab: Table[U, V]): JlValue =
  result = jlEval("Dict()")
  for name, field in tab:
    discard jlCall(JlBase, "setindex!", result, toJlVal(field), name)

