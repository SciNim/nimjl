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
    * Supports complex Arrays

  * map / apply / reduce /fold

  * Map mutable struct to Nim object

### Backlog

* Add support for Enum types

* GPU Support (or is CUDA.jl enough ?)

* Support Julia chaining syntax

* Add a tag for tracing for Julia memory allocation

## Limitations

* Value conversion Nim ==> Julia are done **by copy**.
  * Arrays are an exception to this rule and can be created from buffer / are accessible using a buffer.
* Value conversion Julia => Nim s always done **by copy**
  * When using Arrays you can access the buffer as ``ptr UncheckedArray`` of the Julia Arrays with ``rawData()``.
  * Using ``to(seq[T])`` or ``to(Tensor[T])`` perform a ``copyMem`` of ``jlArray.rawData()`` in your seq/Tensor

* Julia allocated arrays only goes up to 3 dimensions (but Arrays can be allocated in Nim)

* Linux / WSL supports only
  * So I far, I haven't taken the times to create a dedicated syntax to link on Windows. Otherwise, most of it should work
  * I still accept PR aiming at improving Windows supports.
  * You can uncomment in ``.github/workflows/ci.yml`` the Windows part to run the CI on a fork

# Examples

Here is the basic API usage :
```nim
import nimjl

Julia.init() # Initialize Julia VM. Subsequent call will be ignored

var myval = 4.0'f64
# Call Julia function "sqrt" and convert the result to a float
var res = Julia.sqrt(myval).to(float64)
echo res # 2.0

```

Take a look at the ``examples/`` folder for  more examples.

# Documentation

Complete API documentation remains a TODO.

# Contributions

All contributions are welcomed !

# License

This project is released under MIT License.
