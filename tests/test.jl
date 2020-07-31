module custom_module 
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function testMeBaby(A)
    println("From Julia: ", A)
    B = A .* A 
    println("From Julia: ", B)
    return B
  end

  function mutateMeBaby!(A)
    println("From Julia: ", A)
    lmul!(10, A)
    A[1] = 111.11
    println("From Julia: ", A)
  end

  export dummy
  export testMeBaby
  export mutateMeBaby!
end
