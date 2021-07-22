import ../types
import ../cores
import ../functions

import std/[strformat]

proc JlColon*(): JlValue =
  jlCall(JlBase, "Colon")

proc makerange*(start, stop: int, step: int): JlValue =
  let makerangestr = (&"{start}:{step}:{stop}")
  jlEval(makerangestr)

proc makerange*(start, stop: int): JlValue =
  let makerangestr = (&"{start}:{stop}")
  jlEval(makerangestr)

