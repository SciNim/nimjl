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

  export dummy
  export squareMeBaby!
  export mutateMeByTen!
end
