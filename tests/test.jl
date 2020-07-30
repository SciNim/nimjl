module custom_module 
  using LinearAlgebra

  function dummy()
    println("Hello world from dummy")
  end


  function testMeBaby(A)
    println(typeof(A))
    println(A)
    B = lmul!(10, A)
    println(B)
    println(size(B))
    println(ndims(B))
    return B
  end

  export testMeBaby
  export dummy
end
