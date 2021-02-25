module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function modString(inputStr)
    println("Input string: ", inputStr)
    return inputStr * " This is an amazing string"
  end

  function printDict(dict)
    println(dict)
    if dict["12"] != 36.36 && dict["13"] == 48.48
      return true
    else
      return false
    end
  end

  function squareMeBaby(A)
    ## Square array and return the result
    println(typeof(A))
    B = A.*A
    return B
  end

  function mutateMeByTen!(A)
    ## Multiple array in place by ten
    lmul!(10, A)
  end

  function tupleTest(tt)
    ## test tuple creation with specific values
    if (tt.a == 124) && (tt.c - 67.32147 < 1e-8)
      return 255
    end
    return 0
  end

  export dummy
  export tupleTest
  export modString
  export printDict
  export squareMeBaby
  export mutateMeByTen!
end
