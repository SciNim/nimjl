import sequtils
import unittest
import nimjl
import nimjl/sugar/valindexing
import nimjl/arrays/indexing

proc checkTup(tup: JlValue) =
  let reftup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
  if jltypeof(tup) != jltypeof(reftup):
    echo jltypeof(tup)
    echo jltypeof(reftup)
    echo tup
    echo reftup
    assert(false)
  echo ""

proc index1darray() =
  suite "Index 1D Array":
    setup:
      let locarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
      let reflocarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()

    test "$":
      check $locarray == "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]"
      check locarray == reflocarray

    test "[^2]":
      let tmp = locarray[^2]
      check tmp == toJlValue(11)

    test "[_]":
      let tmp = locarray[_]
      check tmp == locarray

    test "[2]":
      let tmp = locarray[2]
      check tmp == toJlValue(2)

    test "[_.._]":
      let tmp = locarray[_.._]
      check tmp == locarray

    test "[2.._]":
      let tmp = locarray[2.._]
      check tmp == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()

    test "[_.._|+2]":
      let tmp = locarray[_.._|+2]
      check tmp == [1, 3, 5, 7, 9, 11].toJlArray()

    test "[1..9|+2]":
      let tmp = locarray[1..9|+2]
      check tmp == [1, 3, 5, 7, 9].toJlArray()

    test "[1..<9|+2]":
      let tmp = locarray[1..<9|+2]
      check tmp == [1, 3, 5, 7].toJlArray()

    test "[1..^2|+2]":
      let tmp = locarray[1..^2|+2]
      check tmp == [1, 3, 5, 7, 9, 11].toJlArray()

    test "[1..6]":
      let tmp = locarray[1..6]
      check tmp == [1, 2, 3, 4, 5, 6].toJlArray()

    test "[1..<8]":
      let tmp = locarray[1..<8]
      check tmp == [1, 2, 3, 4, 5, 6, 7].toJlArray()

    test "[1..^4]":
      let tmp = locarray[1..^4]
      check tmp == [1, 2, 3, 4, 6, 7, 8, 9].toJlArray()

proc checklocarray[T](locarray: JlArray[T]) =
  let refarray = [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220]].toJlArray()
  if jltypeof(refarray) != jltypeof(locarray):
    echo jltypeof(refarray)
    echo jltypeof(locarray)
    echo locarray
    echo refarray
    check false
  echo ""

# proc index2darray() =
#   suite "Index 2D Arrays":
#     setup:
#       let locarray = [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220]].toJlArray()
#
#     test "[^2]":
#       let tmp = locarray[^2, 1]
#       echo "---------------------"
#       echo ">> ", tmp
#       checklocarray(locarray)
#       check
#
#       echo "[_]"
#       echo "---------------------"
#       echo ">> ", locarray[_]
#       checklocarray(locarray)
#
#       echo "[2]"
#       echo "---------------------"
#       echo ">> ", locarray[2]
#       checklocarray(locarray)
#
#       echo "[_.._]"
#       echo "---------------------"
#       echo ">> ", locarray[_.._]
#       checklocarray(locarray)
#
#       echo "[2.._]"
#       echo "---------------------"
#       echo ">> ", locarray[2.._]
#       checklocarray(locarray)
#
#       echo "[_.._|+2]"
#       echo "---------------------"
#       echo ">> ", locarray[_.._|+2]
#       checklocarray(locarray)
#
#       echo "[1..9|+2]"
#       echo "---------------------"
#       echo ">> ", locarray[1..9|+2]
#       checklocarray(locarray)
#
#       echo "[1..<9|+2]"
#       echo "---------------------"
#       echo ">> ", locarray[1..<9|+2]
#       checklocarray(locarray)
#
#       echo "[1..^2|+2]"
#       echo "---------------------"
#       echo ">> ", locarray[1..^2|+2]
#       checklocarray(locarray)
#
#       echo "[1..6]"
#       echo "---------------------"
#       echo ">> ", locarray[1..6]
#       checklocarray(locarray)
#
#       echo "[1..<8]"
#       echo "---------------------"
#       echo ">> ", locarray[1..<8]
#       checklocarray(locarray)
#
#       echo "[1..^4]"
#       echo "---------------------"
#       echo ">> ", locarray[1..^4]
#       checklocarray(locarray)
#
proc indextuple() =
  suite "Index Tuple":
    setup:
      let tup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()

    test "RunMeBaby":
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

proc main() =
  Julia.init()
  indextuple()
  index1darray()
  # index2darray()
  Julia.exit()

when isMainModule:
  when defined(tindex):
    main()
