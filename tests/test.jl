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
    if tt.a != 123
      return false
    end
    if tt.b - (-11.11e-3) > 1e-12
      return false
    end
    if tt.c - 67.32147 > 1e-12
      return false
    end
    if tt.d != "azerty"
      return false
    end
    if tt.e != nothing
      return false
    end
    return true
  end

  function makeMyTuple()
    return (A=1, B=2, C=3,)
  end

  function nestedTuples(o)
    if (o.a.dict["A"] == 1.0 && o.a.dict["B"] == 2.0)
      if(o.a.dat == collect(1:1:10))
        if o.b.x == 36 && o.b.y == 48 && o.b.z == 60
          return true
        end
      end
    end
    return false

  end

  export dummy
  export tupleTest
  export modString
  export printDict
  export dictInvert!
  export makeMyTuple
  export squareMeBaby
  export mutateMeByTen!
  export nestedTuples
end
