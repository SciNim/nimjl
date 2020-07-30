module custom_module 
  using LinearAlgebra

  function dummy()
    println("Hello world from dummy")
  end

  function testMeBaby(A)
    println(A)
    B = A .* A 
    println(B)
    return B
  end

  function mutateMeBaby!(A)
    println(A)
    lmul!(10, A)
    A[1] = 111.11
    println(A)
  end

  export dummy
  export testMeBaby
  export mutateMeBaby!
end
