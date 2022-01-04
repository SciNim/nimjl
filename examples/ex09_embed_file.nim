import nimjl

proc main_1() =
  # Alias for JlEmbed
  Julia.Embed:
    dir("jlassets/")
    file("localasset.jl")

  Julia.init()

  discard Julia.HelloWorld1()
  discard Julia.HelloWorld2()

  block:
    let res = Julia.meanAB(12, 16)
    echo res

  block:
    let res = Julia.squareDiv(9.3, 8.0)
    echo res

proc main_2() =
  # Alias for JlEmbedDir
  Julia.embedDir("jlassets/")
  # Alias for JlEmbedFile
  Julia.embedFile("localasset.jl")

  Julia.init()

  discard Julia.HelloWorld1()
  discard Julia.HelloWorld2()

  block:
    let res = Julia.meanAB(12, 16)
    echo res

  block:
    let res = Julia.squareDiv(9.3, 8.0)
    echo res

proc main_3() =
  Julia.init:
    dir("jlassets/")
    file("localasset.jl")

  discard Julia.HelloWorld1()
  discard Julia.HelloWorld2()

  block:
    let res = Julia.meanAB(12, 16)
    echo res

  block:
    let res = Julia.squareDiv(9.3, 8.0)
    echo res

