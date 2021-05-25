import std/strformat
import std/monotimes
import std/osproc
import std/times
import std/os


import ./testfull
import ./iteratorstest
import ./indexingtest
import ./arraymancertensortest
import ./conversionstest

## Mem Leak Tests
proc memLeakTest*(maxDuration: Duration) =
  # run Externals include module so ran it first and only once
  runExternalsTest()
  runSimpleTests()

  let begin = getMonoTime()
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)
  let deltaTest = initDuration(seconds = 1)
  var maxDuration = maxDuration + 4*deltaTest

  while elapsed <= maxDuration:
    elapsed = getMonoTime() - begin
    runConversionsTest()
    sleep(deltaTest.inMilliseconds().int)

    run1DArrayTest()
    sleep(deltaTest.inMilliseconds().int)

    runArrayArgsTest()
    sleep(deltaTest.inMilliseconds().int)

    runTensorArgsTest()
    sleep(deltaTest.inMilliseconds().int)

    runIteratorsTest()
    sleep(deltaTest.inMilliseconds().int)

    runIndexingTest()
    sleep(deltaTest.inMilliseconds().int)

  # Bye bye Julia
  echo GC_getStatistics()
  sleep(deltaTest.inMilliseconds().int)


proc runMemLeakTest*(srcName: string) =
  var pngName = "memgraph.png"
  let cmdStr = &"./graphMem.sh {srcName} {pngName} &"
  echo cmdStr
  discard execCmd(cmdStr)
  sleep(200)
  let maxDuration = initDuration(seconds = 60'i64, nanoseconds = 0'i64)

  memLeakTest(maxDuration)

when isMainModule:
  import nimjl
  import strutils
  var
    srcPath = currentSourcePath()
    srcName = srcPath.extractFilename()
  srcName.removeSuffix(".nim")

  # Hello Julia
  Julia.init()
  runMemLeakTest(srcName)
  Julia.exit()

