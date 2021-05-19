import nimjl

Julia.init()
jlInclude("tests/test2.jl")
discard Julia.example()
Julia.exit()
