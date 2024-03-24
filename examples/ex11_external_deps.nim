import nimjl

proc main() =
  ## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
  Julia.init(1):
    Pkg:
      add(name="Polynomials", version="3.0.0")
      add(name="LinearAlgebra")
      add("DSP")

  Julia.useModule("Pkg")
  let jlpkg = Julia.getModule("Pkg")
  discard jlpkg.status()

  Julia.exit()

when isMainModule:
  main()
