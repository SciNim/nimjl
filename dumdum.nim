import nimjl

let
  pkgname2 = "LinearAlgebra"
  pkgname1 = "Polynomials"
  pkgversion = "3.0.0"

Julia.init(1):
  Pkg:
    # add(pkgname1, pkgversion)
    # add(pkgname2)
    add(name=pkgname1, version=pkgversion)
    add(name=pkgname2)


