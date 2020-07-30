module AAA
export testMeBaby
  using LinearAlgebra
  function testMeBaby(A)
    println(typeof(A))
    println(A)
    B = lmul!(10, A)
    println(B)
    println(size(B))
    println(ndims(B))
    return B
  end
end
