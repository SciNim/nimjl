import strformat
import osproc
import os

proc checkLeak() =
  const srcName = "checkleak"
  const nimExt = "nim"
  const srcFile = "tests" / srcName & "." & nimExt
  const pngName = "memgraph.png"
  let cmdStr = &"./graphMem.sh {srcName} {pngName}  & nim r {srcFile}"
  echo cmdStr
  discard execCmd(cmdStr)

when defined(checkMemLeak):
  checkLeak()

