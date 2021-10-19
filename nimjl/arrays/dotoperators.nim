import ../types
import ../functions
import ../conversions
import ../glucose

import ./interop

import std/macros

# Arrays operator
# Comparaison
proc equal*[T](val1, val2: JlArray[T]): bool =
  jlCall("==", val1, val2).to(bool)

template `==`*[T](val1, val2: JlArray[T]): bool =
  val1.equal(val2)

# Dot operators
# Broadcasted addition
template jlBroadcast*[T](f: JlFunc, arr: JlArray[T], args: varargs[untyped]): untyped =
  jlCall("broadcast", f, arr, args)

template jlBroadcast*[T](f: string, arr: JlArray[T], args: varargs[untyped]): untyped =
  jlCall("broadcast", getJlFunc(f), arr, args)

macro jlBroadcast*(f: untyped, args: varargs[untyped]): untyped =
  var expr = f.toStrLit.strVal
  quote:
    let f = getJlFunc(`expr`)
    jlCall("broadcast", f, `args`)

proc `+.`*[T: SomeInteger, U: SomeInteger](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`+`, val, factor).toJlArray(T)

proc `+.`*[T: SomeInteger, U: SomeFloat](val: JlArray[T], factor: U|JlArray[U]): JlArray[U] =
  jlBroadcast(`+`, val, factor).toJlArray(U)

proc `+.`*[T: SomeFloat, U: SomeNumber](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`+`, val, factor).toJlArray(T)

proc `-.`*[T: SomeInteger, U: SomeInteger](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`-`, val, factor).toJlArray(T)

proc `-.`*[T: SomeInteger, U: SomeFloat](val: JlArray[T], factor: U|JlArray[U]): JlArray[U] =
  jlBroadcast(`-`, val, factor).toJlArray(U)

proc `-.`*[T: SomeFloat, U: SomeNumber](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`-`, val, factor).toJlArray(T)

proc `*.`*[T: SomeInteger, U: SomeInteger](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`*`, val, factor).toJlArray(T)

proc `*.`*[T: SomeInteger, U: SomeFloat](val: JlArray[T], factor: U|JlArray[U]): JlArray[U] =
  jlBroadcast(`*`, val, factor).toJlArray(U)

proc `*.`*[T: SomeFloat, U: SomeNumber](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`*`, val, factor).toJlArray(T)

# ./ division is a special case
proc `/.`*[T: SomeInteger, U: SomeNumber](val: JlArray[T], factor: U|JlArray[U]): JlArray[float] =
  jlBroadcast(`/`, val, factor).toJlArray(float)

proc `/.`*[T: SomeFloat, U: SomeNumber](val: JlArray[T], factor: U|JlArray[U]): JlArray[T] =
  jlBroadcast(`/`, val, factor).toJlArray(T)

