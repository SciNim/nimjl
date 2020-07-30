module custom_module 
  using LinearAlgebra

  function dummy()
    println("Hello world from dummy")
  end

  function testMeBaby(A)
    println(A)
    B = lmul!(10, A)
    println(B)
    return B
  end

  function mutateMeBaby!(A)
    println(A)
    A = lmul!(10, A)
    println(A)
  end

  export dummy
  export testMeBaby
  export mutateMeBaby!
end
