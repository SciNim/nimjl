import osproc
import strformat

proc checkLeak() =
  const srcName = "testleak"
  const nimExt = "nim"
  const srcFile = srcName & "." & nimExt
  const pngName = "memgraph.png"
  discard execCmd(&"./graphMem.sh {srcName} {pngName}  & nim r {srcFile}")

when defined(checkMemLeak):
  checkLeak()

