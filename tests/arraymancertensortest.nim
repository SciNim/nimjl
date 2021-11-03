import std/unittest
import std/sequtils
import std/options
import std/sugar

import std/strformat

import arraymancer
import nimjl

### Tensor Args
proc tensorSquareMeBaby() =
  test "squareMeBaby[Tensor]":
    let dims = [18, 21, 33]
    var
      orig: Tensor[float64] = ones[float64](dims)
      index = 0
    for i in orig.mitems:
      i = index.float64 / 3.0
      inc(index)

    var xTensor = jlArrayFromBuffer[float64](orig)

    block:
      var
        len_ret = len(xTensor)
        rank_ret = ndims(xTensor)
      check len_ret == orig.size
      check rank_ret == orig.rank

      var
        d0 = dim(xTensor, 0)
        d1 = dim(xTensor, 1)
        d2 = dim(xTensor, 2)
      check @[d0, d1, d2] == orig.shape.toSeq

    var
      ret = toJlArray[float64](Julia.squareMeBaby(xTensor))
      len_ret = len(ret)
      rank_ret = ndims(ret)

    check len_ret == orig.size
    check rank_ret == 3

    var tensorData = ret.to(Tensor[float])
    check tensorData == square(orig)

proc tensorMutateMeBaby() =
  test "mutateMeByTen[Tensor]":
    let dims = [14, 12, 10]

    var
      orig: Tensor[float64] = ones[float64](dims)
      index = 0
    for i in orig.mitems:
      inc(index)
      i = index.float64 / 3.0

    # Create a deepcopy immutable with the expected result
    let tensorcmp = orig.map(x => x*10)

    var
      # ! is a special character in Nim but not in Julia so backticks are necessary
      ret = toJlArray[float](Julia.`mutateMeByTen!`(orig))
      len_ret = len(ret)
      rank_ret = ndims(ret)

    check not isNil(ret)
    check len_ret == orig.size
    check rank_ret == 3

    # Check result is correct
    check orig == tensorcmp

proc tensorBuiltinRot180() =
  test "rot180[Tensor]":
    var
      orig_tensor = newTensor[float64](4, 3)
      index = 0

    for i in orig_tensor.mitems:
      i = index.float64
      inc(index)

    var
      xArray = jlArrayFromBuffer[float64](orig_tensor)
      d0 = dim(xArray, 0).int
      d1 = dim(xArray, 1).int

    check d0 == orig_tensor.shape[0]
    check d1 == orig_tensor.shape[1]

    var ret = toJlArray[float64](Julia.rot180(xArray))
    check not isNil(ret)
    var tensorResData = fromBuffer(ret.getRawData(), ret.shape(), rowMajor)
    orig_tensor.apply_inline: 11.0 - x
    check tensorResData == orig_tensor


proc tensorDotOperator() =
  test "Dot Operators":
    # In Julia broadcast operator is .+
    # In Nimjl, it is translated to +. to avoid being dot-like operator which has different rules
    block:
      var
        origTensor = [[1, 2, 3], [4, 5, 6], [7, 8, 9]].toTensor
        origJlArray = toJlArray(origTensor)
        res = origJlArray +. 3

      origTensor.apply_inline: x+3
      check eltype(res) == jlType(int)
      check res == toJlArray(origTensor)

    block:
      var
        origTensor = [[1, 2, 3], [4, 5, 6], [7, 8, 9]].toTensor
        origJlArray = toJlArray(origTensor)
        res = origJlArray +. 3.0
      var t2 = origTensor.asType(float)
      t2.apply_inline: x+3.0
      check eltype(res) == jlType(float)
      check res == toJlArray(t2)

    block:
      var
        origTensor = toTensor([[1.0'f64, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
        origJlArray = toJlArray(origTensor)
        res = origJlArray +. 3
      origTensor.apply_inline: x+3.0
      check eltype(res) == jlType(float)
      check res == toJlArray(origTensor)

    block:
      var
        origTensor = toTensor([[2.0'f64, 2.0, 2.0], [4.0, 4.0, 4.0], [8.0, 8.0, 8.0]])
        origJlArray = toJlArray(origTensor)
        res = origJlArray /. 2
      origTensor.apply_inline: x/2.0
      check eltype(res) == jlType(float)
      check res == toJlArray(origTensor)

    block:
      var
        origTensor = toTensor([[1.0'f64, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
        origJlArray = toJlArray(origTensor)
        res = jlBroadcast("addValue", origJlArray, 6).toJlArray(float)
      origTensor.apply_inline: x+6.0
      check eltype(res) == jlType(float)
      check res == toJlArray(origTensor)

proc tensorRowMemLayout() =
  test "RowMajor layout":
    var
      rowMajTensor = toTensor([
        [1.0'f64, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
      ])
      rowMajJlArray = toJlArray(rowMajTensor).swapMemoryOrder()

    for i in 0..<rowMajTensor.size:
      check rowMajTensor.atContiguousIndex(i) == Julia.getindex(rowMajJlArray, i+1).to(float)
      check rowMajTensor.toUnsafeView()[i] == rowMajJlArray.getRawData()[i]

proc get2DCoord(index: int, Nx, Ny: int): array[2, int] {.inline.} =
  var index = index
  result[0] = index div Ny
  index = index - result[0]*Ny
  result[1] = index

proc tensorColMemLayout() =
  test "ColMajor layout":
    var
      rowMajTensor = toTensor([
        [1.0'f64, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
      ])

    var
      colMajTensor = rowMajTensor.clone(colMajor)
      colMajJlArray = toJlArray(colMajTensor)
      colTesTensor = colMajJlArray.to(Tensor[float], colMajor)

    check colTesTensor == colMajTensor
    check rowMajTensor == colMajTensor

    for i in 0..<colMajTensor.size:
      # Check buffer are identical
      check colTesTensor.toUnsafeView()[i] == colMajJlArray.getRawData()[i]
      check colMajTensor.toUnsafeView()[i] == colTesTensor.toUnsafeView()[i]
      if i notin {0, 4, 8}:
        check colTesTensor.toUnsafeView()[i] != rowMajTensor.toUnsafeView()[i]
        check colMajTensor.toUnsafeView()[i] != rowMajTensor.toUnsafeView()[i]
      else:
        # Account for symetrical index i.e. index that are identical in row/col Major
        check colTesTensor.toUnsafeView()[i] == rowMajTensor.toUnsafeView()[i]
        check colMajTensor.toUnsafeView()[i] == rowMajTensor.toUnsafeView()[i]

      # Check indexing is identical
      check colTesTensor.atContiguousIndex(i) == rowMajTensor.atContiguousIndex(i)
      check colMajTensor.atContiguousIndex(i) == rowMajTensor.atContiguousIndex(i)
      check colMajTensor.atContiguousIndex(i) == colTesTensor.atContiguousIndex(i)

      var
        coord = get2DCoord(i, 3, 3)
        nx = coord[0]
        ny = coord[1]
      check colTesTensor[nx, ny] == toJlValue(colMajJlArray[nx+1, ny+1]).to(float)
      check rowMajTensor[nx, ny] == toJlValue(colMajJlArray[nx+1, ny+1]).to(float)
      check colMajTensor[nx, ny] == toJlValue(colMajJlArray[nx+1, ny+1]).to(float)

proc runTensorArgsTest*() =
  suite "Tensor":
    teardown: jlGcCollect()
    tensorSquareMeBaby()
    tensorMutateMeBaby()
    tensorBuiltinRot180()
    tensorDotOperator()
    tensorRowMemLayout()
    tensorColMemLayout()


when isMainModule:
  import ./testfull
  Julia.init()
  runExternalsTest()
  runTensorArgsTest()
