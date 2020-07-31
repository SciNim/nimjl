module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function squareMeBaby(A)
    println("From Julia: ", A)
    B = A .* A
    println("From Julia: ", B)
    return B
  end

  function mutateMeByTen!(A)
    println("From Julia: ", A)
    lmul!(10, A)
    println("From Julia: ", A)
  end

  function printArray(A)
    println(ndims(A))
    println(size(A))
    println(length(A))
  end

  export dummy
  export squareMeBaby
  export mutateMeByTen!
  export printArray
end
