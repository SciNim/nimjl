# Nim-Julia bridge

![workflow](https://github.com/Clonkk/nimjl/actions/workflows/ci.yml/badge.svg)

## Prerequisite

* Install Julia version 1.5.3 or above. Version 1.6.6 or above is recommended.
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

* Avoid using global scope for Julia function call. Always have everything inse proc / func. It's good practice anyway

* Value conversion Nim -> Julia are done **by copy**.
  * Arrays are an exception to this rule and can be created from buffer / are accessible using a buffer.

* Value conversion Julia -> Nim s always done **by copy**
  * When using Arrays you can access the buffer as ``ptr UncheckedArray`` of the Julia Arrays with ``rawData()``.
  * Using ``to(seq[T])`` or ``to(Tensor[T])`` perform a ``copyMem`` of ``jlArray.rawData()`` in your seq/Tensor

* Julia allocated arrays only goes up to 3 dimensions (but Arrays can be allocated in Nim)

* Linux / WSL supports only
  * Windows dynamic library linking is different than Linux.
  * If you need Windows support, consider opening an issue or a PR :).
  * Otherwise, just use WSL

# Examples & tips

## Examples

Here is the basic example:
```nim
import nimjl
proc main() =
 Julia.init() # Initialize Julia VM. Subsequent call will be ignored
 
 var myval = 4.0'f64
 # Call Julia function "sqrt" and convert the result to a float
 var res = Julia.sqrt(myval).to(float64)
 echo res # 2.0

when isMainModule:
  main()

```

JlVmExit() seems optionnal. It's present in the C API but not calling it doesn't seem to cause any problem.

Nonetheless, if you use OS resources from Julia it is probably better to call Julia.exit() / JlVmExit() for a clean exit.

## Setting up Julia dependency

* It is now possible to embed Julia files inside a Nim compiled binary to easily distribute Julia code. To make distribution possible, an API to call ``Pkg.add("...")`` has also been added **with version number easy to specify**.

```nim
import nimjl

Julia.init:
  Pkg:
    add(name="Polynomials", version="3.0.0")
    add(name="LinearAlgebra")
    add("DSP")
    add(name="Wavelets", version="0.9.4")

  Embed:
    # embed all files with '*.jl' extension in folder ``JuliaToolBox/``
    dir("JuliaToolBox/")
    # embed all files with '*.jl' extension in the folder of he source file (at compilation) i.e. ``getProjectPath()`` 
    thisDir()
    # embed specific file; path should be relative to ``getProjectPath()``
    file("localfile.jl")
```

Note that the order of the file matters.
See examples/ex09_embed_file.nim for a concrete example. 

Take a look at ``tests/`` or ``examples/`` folder for typical examples.

* You can use Pkg: activate() to setup a virtual env
  * Alternatively, you can embed a Julia file that setup your environment and dependencies and embed it **first**.
  * Because files are evaluated in the order they are embedded, it will deterine the env for all the other files.

## Debugging

* Most error will come from incorrect type passed between Julia and Nim. Check function interface and return type first.

* If you have random segfault that are non-reproductible, that may be a cause of the Julia GC cleaning memory that Nim uses. Consider using jlGcRoot.

* If you do not work with fixed version package for Julia, you are at risk of code breaking when packages are updated / upgraded. 


# License

This project is released under MIT License.
