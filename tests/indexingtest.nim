import sequtils
import unittest
import nimjl

proc let_indextuple() =
  let tup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
  test "Tuple":
    check tup[^2] == toJlValue(11)
    check tup[_] == tup
    check tup[2] == toJlValue(2)
    check tup[_.._] == tup
    check tup[2.._] == (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
    check tup[_.._|+2] == (1, 3, 5, 7, 9, 11).toJlValue()
    check tup[1..9|+2] == (1, 3, 5, 7, 9).toJlValue()
    check tup[1..<9|+2] == (1, 3, 5, 7).toJlValue()
    check tup[1..^2|+2] == (1, 3, 5, 7, 9, 11).toJlValue()
    check tup[1..6] == (1, 2, 3, 4, 5, 6).toJlValue()
    check tup[1..<8] == (1, 2, 3, 4, 5, 6, 7).toJlValue()
    check tup[1..^4] == (1, 2, 3, 4, 5, 6, 7, 8, 9).toJlValue()

proc let_index1darray() =
  let locarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
  test "1DArray":
    check $locarray == "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]"
    let reflocarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray == reflocarray
    check locarray[_] == reflocarray

    # No idea why this produce a fill result
    check locarray[^2] == toJlValue(11)
    check locarray[2] == toJlValue(2)

    check locarray[_.._] == locarray
    check locarray[2.._] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[_.._|+2] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..9|+2] == [1, 3, 5, 7, 9].toJlArray()
    check locarray[1..<9|+2] == [1, 3, 5, 7].toJlArray()
    check locarray[1..^2|+2] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..6] == [1, 2, 3, 4, 5, 6].toJlArray()
    check locarray[1..<8] == [1, 2, 3, 4, 5, 6, 7].toJlArray()
    check locarray[1..^4] == [1, 2, 3, 4, 5, 6, 7, 8, 9].toJlArray()

proc let_index2darray() =
  let locarray = toJlArray([[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220]]).swapMemoryOrder()

  test "2DArray":
    check locarray[^2, 1] == toJlValue(11)
    check locarray[_, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[2, 1] == toJlValue(2)
    check locarray[_.._, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[2.._, 1] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[_.._|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..9|+2, 1] == [1, 3, 5, 7, 9].toJlArray()
    check locarray[1..<9|+2, 1] == [1, 3, 5, 7].toJlArray()
    check locarray[1..^2|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..6, 1] == [1, 2, 3, 4, 5, 6].toJlArray()
    check locarray[1..<8, 1] == [1, 2, 3, 4, 5, 6, 7].toJlArray()
    check locarray[1..^4, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9].toJlArray()

proc var_indextuple() =
  var tup = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
  test "Tuple":
    check tup[^2] == toJlValue(11)
    check tup[_] == tup
    check tup[2] == toJlValue(2)
    check tup[_.._] == tup
    check tup[2.._] == (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12).toJlValue()
    check tup[_.._|+2] == (1, 3, 5, 7, 9, 11).toJlValue()
    check tup[1..9|+2] == (1, 3, 5, 7, 9).toJlValue()
    check tup[1..<9|+2] == (1, 3, 5, 7).toJlValue()
    check tup[1..^2|+2] == (1, 3, 5, 7, 9, 11).toJlValue()
    check tup[1..6] == (1, 2, 3, 4, 5, 6).toJlValue()
    check tup[1..<8] == (1, 2, 3, 4, 5, 6, 7).toJlValue()
    check tup[1..^4] == (1, 2, 3, 4, 5, 6, 7, 8, 9).toJlValue()

proc var_index1darray() =
  var locarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
  test "1DArray":
    check $locarray == "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]"
    let reflocarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray == reflocarray
    check locarray[_] == reflocarray

    # No idea why this produce a fill result
    check locarray[^2] == fill(11)
    check locarray[2] == fill(2)

    check locarray[_.._] == locarray
    check locarray[2.._] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[_.._|+2] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..9|+2] == [1, 3, 5, 7, 9].toJlArray()
    check locarray[1..<9|+2] == [1, 3, 5, 7].toJlArray()
    check locarray[1..^2|+2] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..6] == [1, 2, 3, 4, 5, 6].toJlArray()
    check locarray[1..<8] == [1, 2, 3, 4, 5, 6, 7].toJlArray()
    check locarray[1..^4] == [1, 2, 3, 4, 5, 6, 7, 8, 9].toJlArray()

proc var_index2darray() =
  var locarray = toJlArray([[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220]]).swapMemoryOrder()

  test "2DArray":
    check locarray[^2, 1] == fill(11)
    check locarray[_, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[2, 1] == fill(2)
    check locarray[_.._, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[2.._, 1] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
    check locarray[_.._|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..9|+2, 1] == [1, 3, 5, 7, 9].toJlArray()
    check locarray[1..<9|+2, 1] == [1, 3, 5, 7].toJlArray()
    check locarray[1..^2|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
    check locarray[1..6, 1] == [1, 2, 3, 4, 5, 6].toJlArray()
    check locarray[1..<8, 1] == [1, 2, 3, 4, 5, 6, 7].toJlArray()
    check locarray[1..^4, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9].toJlArray()

proc assign_index1darray() =
  var refarray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  var locarray = jlArrayFromBuffer(refarray)

  test "1DArray":
    locarray[1] = 12
    check refarray[0] == 12
    # locarray[2.._|+2] = 36
    check refarray == @[12, 36, 3, 36, 5, 36, 6, 36, 8, 36, 10, 36, 12]

# proc var_index2darray() =
#   var locarray = toJlArray([[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220]]).swapMemoryOrder()
#
#   test "2DArray":
#     check locarray[^2, 1] == fill(11)
#     check locarray[_, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
#     check locarray[2, 1] == fill(2)
#     check locarray[_.._, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
#     check locarray[2.._, 1] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].toJlArray()
#     check locarray[_.._|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
#     check locarray[1..9|+2, 1] == [1, 3, 5, 7, 9].toJlArray()
#     check locarray[1..<9|+2, 1] == [1, 3, 5, 7].toJlArray()
#     check locarray[1..^2|+2, 1] == [1, 3, 5, 7, 9, 11].toJlArray()
#     check locarray[1..6, 1] == [1, 2, 3, 4, 5, 6].toJlArray()
#     check locarray[1..<8, 1] == [1, 2, 3, 4, 5, 6, 7].toJlArray()
#     check locarray[1..^4, 1] == [1, 2, 3, 4, 5, 6, 7, 8, 9].toJlArray()

proc runIndexingTest*() =
  suite "Immutable Indexing":
    let_indextuple()
    let_index1darray()
    let_index2darray()

  suite "Mutable Indexing":
    var_indextuple()
    var_index1darray()
    var_index2darray()

  suite "Assign Indexing":
    assign_index1darray()

when isMainModule:
  import ./testfull
  Julia.init()
  runExternalsTest()
  runIndexingTest()
  Julia.exit()
