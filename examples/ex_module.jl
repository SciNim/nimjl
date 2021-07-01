# This a dummy Julia module for demonstration purpose
module nimjlExample
  function customFunction(a::NamedTuple)
    println("From Julia -> args = ", a)
    # :nimTupKey is a trick to get the symbol name. It is equivalent to Symbol("nimTupKey1")
    nimTupKey1 = :nimTupKey1
    nimTupKey2 = :nimTupKey2

    # NamedTuple in Julia are immutable so it is necessary to create a new one
    result = (nimTupKey1 = a.nimTupKey1+1, nimTupKey2 = a.nimTupKey2+1)
    return result
  end

  mutable struct Foo
    x::Int
    y::Float64
    z::String
    # Nim initialize the Julia variable with empty constructor by default
    Foo() = new()
    Foo(x, y, z) = new(x, y, z)
  end

  function makeFoo()
    return Foo(1, -1.0, "Hello there")
  end

  function applyToFoo(foo::Foo)
    foo.x += 1
    foo.y *= 2/3
    foo.z *= " -> AppendMeBaby"
  end

  export customFunction
  export Foo
  export makeFoo
  export applyToFoo

end
