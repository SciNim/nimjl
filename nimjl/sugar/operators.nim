# This file is named glucose because it gives you sugar ;)
# It contains most syntactic sugar to ease using Julia inside Nim
import ../types
import ../functions

import ./converttypes
import ../glucose

# typeof is taken by Nim already
proc jltypeof*(x: JlValue): JlValue =
  jlCall("typeof", x)

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

# Julia operators
# Unary operator
proc `+`*(val: JlValue): JlValue =
  Julia.`+`(val)
# Minus unary operator
proc `-`*(val: JlValue): JlValue =
  Julia.`-`(val)

# Arithmetic
proc `+`*(val1, val2: JlValue): JlValue =
  Julia.`+`(val1, val2)

proc `-`*(val1, val2: JlValue): JlValue =
  Julia.`-`(val1, val2)

proc `*`*(val1, val2: JlValue): JlValue =
  Julia.`*`(val1, val2)

proc `/`*(val1, val2: JlValue): JlValue =
  Julia.`/`(val1, val2)

proc `%`*(val1, val2: JlValue): JlValue =
  Julia.`%`(val1, val2)

# Boolean and / or
proc `and`*(val1, val2: JlValue): JlValue =
  Julia.`&&`(val1, val2)

proc `or`*(val1, val2: JlValue): JlValue =
  Julia.`||`(val1, val2)

# Bits && ||
proc bitand*(val1, val2: JlValue): JlValue =
  Julia.`&`(val1, val2)

proc bitor*(val1, val2: JlValue): JlValue =
  Julia.`|`(val1, val2)

proc equal*(val1, val2: JlValue): bool =
  jlCall("==", val1, val2).to(bool)

# # Comparaison
template `==`*(val1, val2: JlValue): bool =
  val1.equal(val2)

proc equal*[T](val1, val2: JlArray[T]): bool =
  jlCall("==", val1, val2).to(bool)

# # Comparaison
template `==`*[T](val1, val2: JlArray[T]): bool =
  val1.equal(val2)


proc `!=`*(val1, val2: JlValue): bool =
  Julia.`!=`(val1, val2).to(bool)

proc `!==`*(val1, val2: JlValue): bool =
  Julia.`!==`(val1, val2).to(bool)

# Assignment
# TODO
# +=, -=, /=, *=
#
# Dot operators
# TODO
# ., .*, ./, .+, .- etc..
