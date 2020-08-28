module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function squareMeBaby!(A)
    A[:]=[i*i for i in A]
  end

  function mutateMeByTen!(A)
    lmul!(10, A)
  end

  function tupleTest(tt)
    if (tt.a == 124) && (tt.c - 67.32147 < 1e-8)
      return 255 
    end
    return 0
  end

  export dummy
  export tupleTest
  export squareMeBaby!
  export mutateMeByTen!
end
