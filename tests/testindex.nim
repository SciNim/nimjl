import sequtils
import unittest
import nimjl
import nimjl/sugar/valindexing

proc checkTup(tup: JlValue) =
  let reftup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
  if jltypeof(tup) != jltypeof(reftup):
    echo jltypeof(tup)
    echo jltypeof(reftup)
    echo tup
    echo reftup
    assert(false)
  echo ""

proc main() =
  block:
    let tup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
    echo "[^2]"
    echo "---------------------"
    echo ">> ", tup[^2]
    checkTup(tup)

    echo "[_]"
    echo "---------------------"
    echo ">> ", tup[_]
    checkTup(tup)

    echo "[2]"
    echo "---------------------"
    echo ">> ", tup[2]
    checkTup(tup)

    echo "[_.._]"
    echo "---------------------"
    echo ">> ", tup[_.._]
    checkTup(tup)

    echo "[2.._]"
    echo "---------------------"
    echo ">> ", tup[2.._]
    checkTup(tup)

    echo "[_.._|+2]"
    echo "---------------------"
    echo ">> ", tup[_.._|+2]
    checkTup(tup)

    echo "[1..9|+2]"
    echo "---------------------"
    echo ">> ", tup[1..9|+2]
    checkTup(tup)

    echo "[1..<9|+2]"
    echo "---------------------"
    echo ">> ", tup[1..<9|+2]
    checkTup(tup)

    echo "[1..^2|+2]"
    echo "---------------------"
    echo ">> ", tup[1..^2|+2]
    checkTup(tup)

    echo "[1..6]"
    echo "---------------------"
    echo ">> ", tup[1..6]
    checkTup(tup)

    echo "[1..<8]"
    echo "---------------------"
    echo ">> ", tup[1..<8]
    checkTup(tup)

    echo "[1..^4]"
    echo "---------------------"
    echo ">> ", tup[1..^4]
    checkTup(tup)

  # block:
  #   let arr = [1.0, 2.0, 3.0].toJlArray()
  #   echo Julia.jltypeof(arr)
  #   echo arr
  #   # Julia arrays are indexed starting at one
  #   let e = arr[1]
  #   echo e
  #
  # block:
  #   let arr2d = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]].toJlArray()
  #   echo Julia.jltypeof(arr2d)
  #   echo toSeq(jlCall("firstindex", arr2d).to(int)..<jlCall("lastindex", arr2d).to(int))
  #   echo jlCall("getindex", arr2d, jlCall(JlBase, "Colon"), toSeq(jlCall("firstindex", arr2d, 2).to(int)..<jlCall("lastindex", arr2d, 2).to(int)))
  #   # echo ">> ", arr2d.shape()
  #   echo ">> ", arr2d[_, 1]
  #   echo ">> ", arr2d[_.._, 1]
  #   echo ">> ", arr2d[_.._|+2, 1]
  # Julia.exit()

when isMainModule:
  when defined(tindex):
    Julia.init()
    main()
    Julia.exit()
