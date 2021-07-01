import nimjl
import sequtils

Julia.init()
# Use Module handle
discard JlMain.println(@[1, 2, 3])
discard Julia.println(toSeq(0..5))

let arr = [1.0, 2.0, 3.0].toJlArray()
# You can now use echo to call println for you on Julia type !
echo jltypeof(arr)
echo arr

# You can also call proc from the value directly
echo arr.stride(1)
echo arr.strides()

Julia.exit()

