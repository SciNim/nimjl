import nimjl
import std/os

# In order to start the Julia VM with threads, the environment variable method is used
proc m1() =
  # So this calls the quivalent of setting : JULIA_NUM_THREADS=4
  Julia.init(4)
  let Threads = jlGetModule("Threads")
  echo Threads.nthreads()
  Julia.exit()

proc m2() =
  # This is the other syntax
  Julia.init(2):
    Pkg: add("DSP")

  let Threads = jlGetModule("Threads")
  echo Threads.nthreads()
  Julia.exit()

when isMainModule:
  m1()
  m2()
