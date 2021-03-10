import strformat
import strutils
import osproc
import os

import times
import testfull

proc checkLeak() =
  var
    srcPath = currentSourcePath()
    srcName = srcPath.extractFilename()
  srcName.removeSuffix(".nim")
  echo srcName
  var
    pngName = "memgraph.png"
  let cmdStr = &"./graphMem.sh {srcName} {pngName} &"
  echo cmdStr
  discard execCmd(cmdStr)
  sleep(200)
  let maxDuration = initDuration(seconds = 60'i64, nanoseconds = 0'i64)
  runMemLeakTest(maxDuration)

when isMainModule:
  when defined(checkMemLeak):
    checkLeak()

