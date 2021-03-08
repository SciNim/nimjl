import sequtils
import sugar
import random
import nimjl

randomize()
jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.
block sort:
  var seqRand : seq[int64] = newSeqWith(12, rand(100)).map(x => x.int64)
  echo seqRand
  # Convert Nim array to Julia array without copy
  var jlRandArray = jlArrayFromBuffer(seqRand)
  # Return a sorted version of the array and do not modify original
  var res = jlCall("sort", jlRandArray)

  # Since the "res" value has been allocated by Julia, it depends on JL's garbage collector
  # Read more about this topic here : https://docs.julialang.org/en/v1/manual/embedding/index.html#Memory-Management
  # If you want to keep "res" allocated thorugh JL's gc cycle, it is necessary to "root the value" using julia_gc_push and julia_gc_pop
  # For convenience, a template jlGcRoot has been defined that does it for you
  # Note that if the value is "used" before the next Gc Cycle (or you copied its content) this is not necessary
  jlGcRoot(res):
  # Template equivalent to :
  # julia_gc_push1(res.addr)

    # toJlArray performs a JlValue -> JlArray conversion
    let
      jlResArray = res.toJlArray(int64)
      arrLen = jlResArray.len()
      resArray = jlResArray.dataArray()

    # dataArray() return a ptr UncheckedArray[T] from a JlArray
    stdout.write("@[")
    for i in 0..<arrLen:
      stdout.write(resArray[i])
      if i != arrLen-1:
        stdout.write(", ")
    stdout.write("]\n")

  # End of Template equivalent to :
  # julia gc pop and julia gc push need to be in the same scope
  # julia_gc_pop()

block sort:
  var seqRand : seq[int64] = newSeqWith(12, rand(100)).map(x => x.int64)
  # Convert Nim array to Julia array without copy
  var jlRandArray = jlArrayFromBuffer(seqRand)
  echo seqRand
  # sort! (notice the "!") modify the original array
  discard jlCall("sort!", jlRandArray)
  # Notice how arrays are passed by buffer and thus this has modified the original seq
  echo seqRand

  jlVmExit() # Exit Julia VM. This can be done only once in the lifetime of your program.
