import arraymancer
import sequtils
import nimjl

proc main() =
  jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.

  # Just be aware that Nim Seq/Tensor are Row Major.
  # Julia usually work in Column major.
  var tensor = randomTensor[float](2, 3, 10.0)
  let evRes = jlEval("""using Pkg; Pkg.add("LinearAlgebra")""")
  doAssert not isNil(evRes)

  jlUseModule("LinearAlgebra")
  # Julia Arrays starts at 1
  var res = jlCall("permutedims", tensor, [2, 1]).toJlArray(float)
  # Check dimensions have changed
  doAssert res.shape() == [3, 2]

  jlVmExit() # Exit Julia VM. This can be done only once in the lifetime of your program.

when isMainModule:
  main()
