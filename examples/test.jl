module AAA
  using LinearAlgebra
  function testMeBaby()
    A = [[1, 2, 3] [4, 5, 6] [7, 8, 9]]
    # C = rand(5,6)
    # print(typeof(C))
    println(typeof(A))

    println(A)
    B = lmul!(10, A)
    println(B)
    println(size(B))
    println(ndims(B))
    return B
  end
end
