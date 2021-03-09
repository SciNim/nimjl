import testfull
import nimjl
import os
import times
import std/monotimes

proc runMemLeakTest*(maxDuration: Duration) =
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()

  let begin = getMonoTime()
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)
  let deltaTest = initDuration(seconds = 10)
  var maxDuration = maxDuration + 4*deltaTest

  while elapsed < maxDuration:
    elapsed = getMonoTime() - begin
    runTupleTest()
    sleep(deltaTest.inMilliseconds().int)
    runArrayTest()
    sleep(deltaTest.inMilliseconds().int)
    runArrayArgsTest()
    sleep(deltaTest.inMilliseconds().int)
    runTensorArgsTest()
    sleep(deltaTest.inMilliseconds().int)

  jlGcCollect()
  echo GC_getStatistics()

  jlVmExit(0)

when isMainModule:
  let maxDuration = initDuration(seconds = 60'i64, nanoseconds = 0'i64)
  runMemLeakTest(maxDuration)

