import nimjl
import sequtils

Julia.init()
# Use Module handle
discard JlMain.println(@[1, 2, 3])
discard Julia.println(toSeq(0..5))

let arr = [1.0, 2.0, 3.0].toJlArray()
# You can now use echo to call println for you on Julia type !
echo Julia.jltypeof(arr)
echo arr

Julia.exit()

