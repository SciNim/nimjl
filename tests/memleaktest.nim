import std/strformat
import std/strutils
import std/monotimes
import std/osproc
import std/times
import std/os

import nimjl

import ./testfull
import ./iteratorstests
import ./arraymancertensortests

## Mem Leak Tests
proc memLeakTest*(maxDuration: Duration) =
  # run Externals include module so ran it first and only once
  runExternalsTest()

  let begin = getMonoTime()
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)
  let deltaTest = initDuration(seconds = 1)
  var maxDuration = maxDuration + 4*deltaTest

  while elapsed <= maxDuration:
    elapsed = getMonoTime() - begin
    runTupleTest()
    sleep(deltaTest.inMilliseconds().int)
    run1DArrayTest()
    sleep(deltaTest.inMilliseconds().int)
    runArrayArgsTest()
    sleep(deltaTest.inMilliseconds().int)
    runTensorArgsTest()
    sleep(deltaTest.inMilliseconds().int)
    runIteratorsTest()
    sleep(deltaTest.inMilliseconds().int)

  # Bye bye Julia
  echo GC_getStatistics()
  sleep(deltaTest.inMilliseconds().int)


proc runMemLeakTest*() =
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

  memLeakTest(maxDuration)

when isMainModule:
  # Hello Julia
  Julia.init()
  runMemLeakTest()
  Julia.exit()

