import nimjl
import arraymancer
import sequtils

proc do1darray() =
  block:
    var s = @[1, 2, 3, 4, 5, 6, 7, 8, 9]
    var s1 = jlArrayFromBuffer[int](s)

    s[0] = 120
    s1[1] = 122
    s1[3, 5, 8] = [123, 124, 125]

    echo s1
    echo s

  block:
    var s = @[1, 2, 3, 4, 5, 6, 7, 8, 9]
    var s1 = toJlArray[int](s)
    jlGcRoot(s1):
      s[0] = 120
      s1[1] = 122
      s1[3, 5, 8] = [123, 124, 125]

      echo s1
      echo s

proc do2darray() =
  block:
    var s = [[1, 2, 3], [4, 5, 6], [7, 8, 9]].toTensor
    var s1 = toJlArray(s)
    # This variable is allocaed by Julia
    # So it's better to root
    jlGcRoot(s1):
      echo s[1, 2]
      echo s1[1, 2]
      s1[1, 2] = 120
      s1[2, 2] = 122

      echo s1
      # Tensor is not modified
      echo s

  block:
    var s = [[1, 2, 3], [4, 5, 6], [7, 8, 9]].toTensor
    var s1 = jlArrayFromBuffer[int](s)
    echo s[1, 2]
    echo s1[1, 2]
    s1[1, 2] = 120
    s1[2, 2] = 122
    echo s1
    # Tensor is modified
    echo s

proc main() =
  Julia.init()
  do1darray()
  do2darray()
  Julia.exit()

main()
