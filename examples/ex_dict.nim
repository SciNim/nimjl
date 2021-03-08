import tables
import nimjl

proc popMe[U, V](tab: Table[U, V], key: U): V =
  # Nim's Table is converted to Julia dict by COPY
  # Therefore "pop!" function will not modify tab
  result = jlCall("pop!", tab, key).to(V)

# JlValue can hold any Julia type
proc popMe[U, V](tab: var JlValue, key: U): V =
  # Nim's Table is converted to Julia dict by COPY
  # Therefore "pop!" function will not modify tab
  result = jlCall("pop!", tab, key).to(V)


jlVmInit() # Initialize Julia VM. This should be done once in the lifetime of your program.

var mytab: Table[int64, float64] = {1'i64: 0.90'f64, 2'i64: 0.80'f64, 3'i64: 0.70'f64}.toTable
block:
  let key = 1
  var poppedValue = popMe(mytab, key)
  # mytab has not been changed due to copy when passing value to Julia
  doAssert key in mytab
  doAssert poppedValue == mytab[key]

block:
  var myJlTab = toJlVal(mytab) # Convert myJlTab to JlValue
  let key = 1
  var poppedValue = popMe[int64, float64](myJlTab, key)
  doAssert not myJlTab.to(Table[int64, float64]).contains(key) # Value was removed from myJlTab
  doAssert poppedValue == mytab[key]

jlVmExit() # Exit Julia VM. This can be done only once in the lifetime of your program.
