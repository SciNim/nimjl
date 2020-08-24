module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function squareMeBaby!(A)
    # println("squareMeBaby!_1D")
    # A = A .* A
    A[:]=[i*i for i in A]
    # return B
  end
  function mutateMeByTen!(A)
    # println("mutateMeBaby_1D")
    lmul!(10, A)
  end


  # function squareMeBaby!(A::Array{Float64, 2})
  #   println("squareMeBaby!_2D")
  #   # A = A .* A
  #   A[:]=[i*i for i in A]
  #   # return B
  # end
  # function mutateMeByTen!(A::Array{Float64, 2})
  #   println("mutateMeBaby_2D")
  #   lmul!(10, A)
  # end


  # function squareMeBaby!(A::Array{Float64, 3})
  #   println("squareMeBaby!_3D")
  #   # A = A .* A
  #   A[:]=[i*i for i in A]
  #   # return B
  # end
  # function mutateMeByTen!(A::Array{Float64, 3})
  #   println("mutateMeBaby_3D")
  #   lmul!(10, A)
  # end

  export dummy
  export squareMeBaby!
  export mutateMeByTen!
end
