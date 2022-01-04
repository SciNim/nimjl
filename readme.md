# Nim-Julia bridge

![workflow](https://github.com/Clonkk/nimjl/actions/workflows/ci.yml/badge.svg)

## Prerequisite

* Install Julia version 1.5.3 or above
* ``julia`` executable must be in your path.
  * By-default, ``nimjl`` will use Julia's ``Sys.BINDIR`` parent directory as the installation folder of Julia.
  * If you want ``nimjl`` to use a specific Julia installation, set the environment variable ``JULIA_PATH`` to the root of the installation folder.
* Run ``nimble install`` or ``nimble develop``

After this steps, ``$JULIA_PATH/include`` should points to Julia header and ``$JULIA_PATH/lib`` should point to ``libjulia.so``

You can also install Julia locally by running ``nimble install julia``, in that case it will install Julia in the ``third_party`` folder

## Ressources

How to embed Julia w/ C :

* https://docs.julialang.org/en/v1/manual/embedding/index.html#Working-with-Arrays-1

* https://github.com/JuliaLang/julia/tree/master/test/embedding

* Read the Scinim getting-started [chapter on Nimjl](https://scinim.github.io/getting-started/external_language_integration/julia/basics.html)

* ``legacy/`` folder contains previous experiment and examples of wrapping in C.

* ``tests/testfull.nim`` is thet test suite

* ``examples/`` contains several examples

## Next steps

Julia is mostly oriented towards numerical computing so Arrays are THE most important data structure to support

### In-progress

Mostly quality-of-life improvements, especially when handling arrays.

* Improve Julia Arrays interop. from Nim.
  * Supports complex Arrays
  * map / apply / reduce /fold

### Backlog

* Support Julia chaining syntax
* Add support for Enum types

## Limitations

* Value conversion Nim -> Julia are done **by copy**.
  * Arrays are an exception to this rule and can be created from buffer / are accessible using a buffer.

* Value conversion Julia -> Nim s always done **by copy**
  * When using Arrays you can access the buffer as ``ptr UncheckedArray`` of the Julia Arrays with ``rawData()``.
  * Using ``to(seq[T])`` or ``to(Tensor[T])`` perform a ``copyMem`` of ``jlArray.rawData()`` in your seq/Tensor

* Julia allocated arrays only goes up to 3 dimensions (but Arrays can be allocated in Nim)

* Linux / WSL supports only
  * Windows dynamic library linking is different than Linux.
  * If you need Windows support, consider opening an issue or a PR :).

# Examples

Here is the basic example:
```nim
import nimjl

Julia.init() # Initialize Julia VM. Subsequent call will be ignored

var myval = 4.0'f64
# Call Julia function "sqrt" and convert the result to a float
var res = Julia.sqrt(myval).to(float64)
echo res # 2.0

```

## New in version 0.7.0

It is now possible to embed Julia files inside a Nim compiled binary to easily distribute Julia code. To make distribution possible, an API to call ``Pkg.add("...")`` has also been added.

```nim
import nimjl

Julia.init:
  Pkg:
    add("DSP")
    add("Wavelets")
    add("LinearAlgebra")
    add("Statistics")

  Embed:
    # embed all files with '*.jl' extension in folder ``JuliaToolBox/``
    dir("JuliaToolBox/")
    # embed all files with '*.jl' extension in the folder of he source file (at compilation) i.e. ``getProjectPath()`` 
    thisDir()
    # embed specific file; path should be relative to ``getProjectPath()``
    file("localfile.jl")
```
See examples/ex09_embed_file.nim for a concrete example 

Take a look at ``tests/`` or ``examples/`` folder for typical examples.

# License

This project is released under MIT License.
