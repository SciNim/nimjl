import ../types
import ../cores
import ../functions
import ../conversions

import ../glucose

proc iterate*(val: JlValue): JlValue =
  result = JlMain.iterate(val)
  if result == JlNothing or len(result) != 2:
    raise newException(JlError, "Non-iterable value")

proc iterate*(val: JlValue, state: JlValue): JlValue =
  result = JlMain.iterate(val, state)

iterator items*(val: JlValue): JlValue =
  var it = iterate(val)
  while it != JlNothing:
    yield it.getindex(1)
    it = iterate(val, it.getindex(2))

iterator enumerate*(val: JlValue): (int, JlValue) =
  var it = iterate(val)
  var i = 0
  while it != JlNothing:
    yield (i, it.getindex(1))
    it = iterate(val, it.getindex(2))
    inc(i)


