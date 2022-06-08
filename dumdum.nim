import nimjl

let
  pkgname2 = "LinearAlgebra"
  pkgname1 = "Polynomials"
  pkgversion = "3.0.0"

Julia.init(1):
  Pkg:
    add(pkgname1, pkgversion)
    add(pkgname2)

# import nimjl
# template init(body : untyped) =
#   var storeMe: seq[tuple[name, version: string]]
#   proc add(name: string, version: string) =
#     let s = (name: name, version: version,)
#     echo s
#     storeMe.add(s)
#   body
#
# proc main() =
#   init:
#     add("example", "1.2.1")
#
# main()

