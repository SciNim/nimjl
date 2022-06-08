import nimjl

## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
Julia.init(1):
  Pkg:
    add(name="Polynomials", version="3.0.0")
    add(name="LinearAlgebra")
    add("DSP")
    add(name="Wavelets", version="0.9.4")
