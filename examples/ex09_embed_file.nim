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



proc main_1() =
  # Alias for JlEmbed
  Julia.Embed:
    dir("jlassets/")
    file("localasset.jl")

  Julia.init()
  defer: Julia.exit()

  common()

proc main_2() =
  # Alias for JlEmbedDir
  Julia.embedDir("jlassets/")
  # Alias for JlEmbedFile
  Julia.embedFile("localasset.jl")

  Julia.init()
  defer: Julia.exit()

  common()

proc main_3() =
  Julia.init:
    dir("jlassets/")
    file("localasset.jl")
  defer: Julia.exit()

  common()

when isMainModule:
  main_3()
