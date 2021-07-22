import std/exitprocs
import std/unittest
import std/os

import nimjl

proc test() =
  test "Init":
    jlVmInit()
    check jlVmIsInit()
    check Julia.sqrt(4.0) == toJlVal(2.0)
    jlInclude("./test.jl")
    jlUseModule(".custom_module")
    jlVmSaveImage("./jlvm.img")

    # expect JlError:
    #   jlVmInit()

when isMainModule:
  test()

