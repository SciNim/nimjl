module custom_module
  using LinearAlgebra

  function dummy()
    println(">> Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function modString(inputStr)
    println(">> Julia says... Input string: ", inputStr)
    return inputStr * " This is an amazing string"
  end

  function printDict(dict, key1, val1, key2, val2)
    println(">> Julia says...", dict)
    if dict[key1] == val1 && dict[key2] == val2
      return true
    else
      return false
    end
  end

  function dictInvert!(dict, key1, val1, key2, val2)
    dict[key2] = val1
    dict[key1] = val2
    println(">> Julia says...", keys(dict))
    return dict
  end


  function squareMeBaby(A)
    ## Square array and return the result
    println(">> Julia says...", typeof(A))
    B = A.*A
    return B
  end

  function mutateMeByTen!(A)
    ## Multiple array in place by ten
    lmul!(10, A)
  end

  function tupleTest(tt)
    ## test tuple args with specific values
    if (tt.a == 124) && (tt.c - 67.32147 < 1e-12)
      return true
    end
    return false
  end

  function makeMyTuple()
    return (A=1, B=2, C=3,)
  end

  export dummy
  export tupleTest
  export modString
  export printDict
  export dictInvert!
  export makeMyTuple
  export squareMeBaby
  export mutateMeByTen!
end
