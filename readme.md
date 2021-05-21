# Nim-Julia bridge 

![workflow](https://github.com/Clonkk/nimjl/actions/workflows/ci.yml/badge.svg)

This is repo is a WIP to be able to call Julia function from Nim using the C-API of Julia.

## Prerequisite

* Install Julia version 1.5.3 or above
* ``julia`` executable must be in your path.
  * By-default, ``nimjl`` will use Julia's ``Sys.BINDIR`` parent directory as the installation folder of Julia.
  * If you want ``nimjl`` to use a specific Julia installation, set the environment variable ``JULIA_PATH`` to the root of the installation folder.
* Run ``nimble install`` or ``nimble develop`` 

After this steps, ``$JULIA_PATH/include`` should points to Julia header and ``$JULIA_PATH/lib`` should point to ``libjulia.so``

You can also install Julia locally by running ``nimble installjulia``, in that case it will install Julia in the ``third_party`` folder 

## Ressources

How to embed Julia w/ C :

* https://docs.julialang.org/en/v1/manual/embedding/index.html#Working-with-Arrays-1

* https://github.com/JuliaLang/julia/tree/master/test/embedding

* ``legacy/`` folder contains previous experiment and examples of wrapping in C. 

* ``tests/testfull.nim`` is thet test suite 

* ``examples/`` contains several examples

## Next steps 

Julia is mostly oriented towards numerical computing so Arrays are THE most important data structure to support

### In-progress

Mostly quality-of-life improvements, especially when handling arrays.

* Improve Julia Arrays interop. from Nim.
  * Create Array API with most common proc
    * Implement Matrix calc. operators : `*`, `+`, `-`, `/`, "Dotted operator" ``*.``, ``+.``, ``-.``, ``/.``
    * Implement ``asType`` function mapped ``Base.reinterpret`` (ref. https://docs.julialang.org/en/v1/base/arrays/#Base.reinterpret) and ``reshape`` with ``Base.reshape``

  * map / apply / reduce /fold
  * Iterators

  * GPU Support ?

### Backlog

* Add support for Enum types

* Map mutable struct to Nim object

* Support Julia chaining syntax

* Add a tag for tracing for Julia memory allocation

## Limitations

* Julia Init / Exit can only be called **once in the lifetime of your program**
* Value conversion Nim ==> Julia are done **by copy** **except for Arrays** type that use a pre-allocated buffer.
* Value conversion Julia => Nim s always done **by copy**
  * When using Arrays you can access the buffer as ``ptr UncheckedArray`` of the Julia Arrays with ``rawData()``. 
  * Using ``to(seq[T])`` or ``to(Tensor[T])`` perform a ``copyMem`` of ``jlArray.rawData()`` in your seq/Tensor 

* Julia allocated arrays only goes up to 3 dimensions (but Arrays can be allocated in Nim)
* Only supports Linux for now

# Examples

Here is the basic API usage : 
```nim
import nimjl

Julia.init() # Initialize Julia VM. This should be done once in the lifetime of your program.

var myval = 4.0'f64
# Call Julia function "sqrt" and convert the result to a float
var res = Julia.sqrt(myval).to(float64)
echo res # 2.0

Julia.exit() # Exit Julia VM. This can be done only once in the lifetime of your program.
```

Take a look at the ``examples/`` folder for  more examples. 

# Documentation

Complete API documentation remains a TODO.

# Contributions

All contributions are welcomed !

# License

This project is released under MIT License.
