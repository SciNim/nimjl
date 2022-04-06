import nimjl

proc common() =
  discard Julia.helloWorld1()
  discard Julia.helloWorld2()

  block:
    let res = Julia.meanAB(12, 16)
    echo res

  block:
    let res = Julia.squareDiv(9.3, 8.0)
    echo res

# All methods accomplish the same result
# main_3 is the cleanest (subjective option) so it should be preferred

proc main_2() =
  # Manual embedding; must be done before init
  jlEmbedDir("jlassets/")
  jlEmbedFile("localasset.jl")

  Julia.init()
  defer: Julia.exit()

  common()

proc main_1() =
  # Idiomatic way to embed Julia ressources and call them during after VM Init
  # The int argument is the number of threads used by the Julia VM
  Julia.init(2):
    # Install package at init
    Pkg:
      add("LinearAlgebra")
    Embed:
      dir("jlassets/")
      file("localasset.jl")
  defer: Julia.exit()

  common()

when isMainModule:
  main_1()
