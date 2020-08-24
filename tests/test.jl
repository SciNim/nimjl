module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function squareMeBaby(A::Array{Float64, 1})::Array{Float64, 1}
    println("squareMeBaby_1D")
    B = A .* A
    return B
  end
  function mutateMeByTen!(A::Array{Float64, 1})
    println("mutateMeBaby_1D")
    lmul!(10, A)
  end


  function squareMeBaby(A::Array{Float64, 2})::Array{Float64, 2}
    println("squareMeBaby_2D")
    B = A .* A
    return B
  end
  function mutateMeByTen!(A::Array{Float64, 2})
    println("mutateMeBaby_2D")
    lmul!(10, A)
  end


  function squareMeBaby(A::Array{Float64, 3})::Array{Float64, 3}
    println("squareMeBaby_3D")
    B = A .* A
    return B
  end
  function mutateMeByTen!(A::Array{Float64, 3})
    println("mutateMeBaby_3D")
    lmul!(10, A)
  end

  export dummy
  export squareMeBaby
  export mutateMeByTen!
end
