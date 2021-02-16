module custom_module
  using LinearAlgebra

  function dummy()
    println("Julia says... Hello, world ! Function dummy() from module custom_module has been executed !")
  end

  function addMeBaby(x, y)
    return x+y
  end

  function squareMeBaby(A)
    #  A = unsafe_wrap(Array, data, len)
    ## Square array and return the result
    println(typeof(A))

    #  A[:]=[i*i for i in A]
    #  return A
    B = A.*A
    return B
    #  return map(x -> x*x, A)
  end

  function mutateMeByTen!(A)
    ## Multiple array in place by ten
    lmul!(10, A)
  end

  export dummy
  export squareMeBaby
  export mutateMeByTen!
  export addMeBaby

  ## TODO Fix this
  #  const julia_dummy = @cfunction(dummy, Cvoid, (Cvoid,))
  #  export julia_dummy

  const julia_addMeBabyInt = @cfunction(addMeBaby, Cint, (Cint, Cint,))
  export julia_addMeBabyInt

  const julia_addMeBabyFloat = @cfunction(addMeBaby, Cfloat, (Cfloat, Cfloat,))
  export julia_addMeBabyFloat
end
