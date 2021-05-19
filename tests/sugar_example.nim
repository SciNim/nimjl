import nimjl
import sequtils
import unittest


proc main() =
  Julia.init()
  # Use Module handle
  discard JlMain.println(@[1, 2, 3])
  block:
    discard Julia.println(toSeq(0..5))

  block:
    let arr = [1.0, 2.0, 3.0].toJlArray()
    echo Julia.jltypeof(arr)
    echo arr
    # Julia arrays are indexed starting at one
    let e = arr[1]
    echo e

  block:
    let arr2d = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]].toJlArray()
    echo Julia.jltypeof(arr2d)
    echo toSeq(jlCall("firstindex", arr2d).to(int)..<jlCall("lastindex", arr2d).to(int))
    echo jlCall("getindex", arr2d, jlCall(JlBase, "Colon"), toSeq(jlCall("firstindex", arr2d, 2).to(int)..<jlCall("lastindex", arr2d, 2).to(int)))
    # echo ">> ", arr2d.shape()
    echo ">> ", arr2d[_, 1]
    echo ">> ", arr2d[_.._, 1]
    echo ">> ", arr2d[_.._|+2, 1]
  Julia.exit()

main()
