import times
import os
import std/monotimes

import nimjl
import test1

proc main() =
  jlVmInit()
  # run Externals include module so ran it first and only once
  runExternalsTest()
  runTests()
  jlVmExit(0)

when isMainModule:
  let begin = getMonoTime()
  let maxDuration = initDuration(seconds = 10'i64, nanoseconds = 0'i64)
  var elapsed = initDuration(seconds = 0'i64, nanoseconds = 0'i64)

  while elapsed < maxDuration:
    elapsed = getMonoTime() - begin
    if elapsed.inSeconds mod 10 == 0:
      echo GC_getStatistics()
    main()
    sleep(500)
