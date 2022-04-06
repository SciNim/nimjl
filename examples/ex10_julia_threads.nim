import nimjl
import std/os

proc main() =
  # This is the other syntax with dependencies
  # It is strictly equivalent to
  # Julia.init(4)
  # Calling Julia.init() is equivalent to calling Julia.init(1)
  Julia.init(4):
    Pkg: add("LinearAlgebra")

  let Threads = jlGetModule("Threads")
  echo Threads.nthreads()
  Julia.exit()

when isMainModule:
  main()
