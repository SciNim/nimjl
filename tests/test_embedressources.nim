import unittest
import nimjl

proc testEmbedRessources*() =
  Julia.init:
    Embed:
      file("embed.jl")
      dir("assets/")

  suite "Embedding File & Dir ":
    test "file ressources":
      let res = Julia.testMe().to(bool)
      check res

    test "dir ressources":
      let res = Julia.testMe2().to(bool)
      check res

  Julia.exit()

when isMainModule:
  testEmbedRessources()
