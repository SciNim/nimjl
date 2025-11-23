## Example demonstrating enhanced error handling in nimjl

import nimjl

proc demonstrateUninitializedError() =
  echo "\n=== Demonstrating Uninitialized Error ==="
  try:
    # This will give a helpful error message
    let result = Julia.sqrt(4.0)
    echo "Result: ", result
  except JlInitError as e:
    echo "Caught expected error:"
    echo e.msg

proc demonstrateNullPointerError() =
  echo "\n=== Demonstrating Null Pointer Error ==="
  Julia.init()

  try:
    # Try to get a non-existent function
    let fn = getJlFunc("this_function_does_not_exist")
    discard jlCall(fn, jlBox(1))
  except JlError as e:
    echo "Caught expected error:"
    echo e.msg

proc demonstrateJuliaException() =
  echo "\n=== Demonstrating Julia Exception with Context ==="
  Julia.init()

  try:
    # This will cause a DivideError in Julia
    let result = jlEval("div(1, 0)")
    echo "Result: ", result
  except JlError as e:
    echo "Caught Julia exception:"
    echo e.msg

proc demonstrateTypeError() =
  echo "\n=== Demonstrating Type Checking ==="
  Julia.init()

  let value = jlBox(42)

  # Good type checking
  echo "Type info: ", getJlTypeInfo(value)

  if jlIsa(value, JlInt64):
    echo "✓ Value is an Int64"
  else:
    echo "✗ Value is not an Int64"

  # Check if it's an array (it's not)
  if jlIsArray(cast[JlValue](value)):
    echo "Value is an array"
  else:
    echo "Value is not an array (correct!)"

proc demonstrateErrorContext() =
  echo "\n=== Demonstrating Error Context ==="
  Julia.init()

  proc innerFunction(x: int) =
    withJlErrorContext(&"processing value {x}"):
      if x < 0:
        discard jlEval("error(\"Negative values not allowed\")")
      let result = Julia.sqrt(x.float.toJlVal)
      echo &"sqrt({x}) = ", result.to(float)

  try:
    innerFunction(16) # This works
    innerFunction(-4) # This will error with context
  except JlError as e:
    echo "Error with context:"
    echo e.msg

proc demonstrateDiagnostics() =
  echo "\n=== Julia Diagnostics ==="

  echo "Before initialization:"
  echo jlDiagnostic()

  Julia.init()

  echo "\nAfter initialization:"
  echo jlDiagnostic()

  echo "\nSystem Image Info:"
  let info = currentSysImageInfo()
  echo "  Path: ", info.path
  echo "  Size: ", info.size div (1024 * 1024), " MB"
  echo "  Is Default: ", info.isDefault

  echo "\nThreading Info:"
  echo "  Number of threads: ", jlNThreads()
  echo "  Current thread: ", jlThreadId()

  echo "\nGC Info:"
  echo "  GC enabled: ", jlGcIsEnabled()

proc main() =
  echo "=== Nimjl Enhanced Error Handling Demo ==="

  # Demonstrate various error scenarios
  demonstrateUninitializedError()
  demonstrateNullPointerError()
  demonstrateJuliaException()
  demonstrateTypeError()
  demonstrateErrorContext()
  demonstrateDiagnostics()

  echo "\n=== Demo Complete ==="

when isMainModule:
  main()
