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

## System Images (v0.9.0+)

For faster startup times, you can create and load precompiled Julia system images:

```nim
import nimjl/sysimage

# Create a system image with packages and code
createAppSysImage(
  "myapp.so",
  packages = ["DataFrames", "Plots"],
  sourceFiles = ["init.jl"],
  sourceDirs = ["src/"]  # Includes all .jl files recursively
)

# Initialize Julia with the custom image
initWithSysImage("myapp.so")
```

System images eliminate recompilation overhead and allow distributing precompiled binaries.

## Error Handling (v0.9.0+)

Enhanced error messages with Julia stack traces in debug mode:

```nim
try:
  discard Julia.myFunction(42)
except JlError as e:
  echo "Julia error: ", e.msg  # Includes context and stack trace
except JlInitError as e:
  echo "VM not initialized: ", e.msg
```

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

## Cross-Compilation

`nimjl` supports cross-compilation for scenarios where you need to compile for a different architecture than your host machine (e.g., compiling on x86_64 for ARM64, or on macOS for Linux).

### Prerequisites

**Important**: Cross-compilation requires the target architecture Julia libraries to be available on your build machine. You must specify the path using either:
- The `-d:JuliaPath="/path/to/target-julia"` compile flag, OR
- The `JULIA_PATH` environment variable

### Usage

Enable cross-compilation mode by adding the `-d:nimjl_cross_compile` flag:

```bash
# Using compile flag (recommended for explicit control)
nim c -d:nimjl_cross_compile \
     -d:JuliaPath="/path/to/arm64-julia" \
     --cpu:arm64 --os:linux \
     myapp.nim

# Using environment variable
export JULIA_PATH=/path/to/arm64-julia
nim c -d:nimjl_cross_compile --cpu:arm64 --os:linux myapp.nim
```

### How It Works

**Normal Mode** (default):
- Queries the Julia binary at compile time: `julia -E VERSION`
- Most reliable, but requires Julia to be installed and runnable on the host
- Auto-detects Julia from `julia` in PATH if not specified

**Cross-Compilation Mode** (`-d:nimjl_cross_compile`):
- Extracts Julia version from the library filename instead
- macOS: `libjulia.1.11.7.dylib` → version 1.11.7
- Linux: `libjulia.so.1.11.7` → version 1.11.7
- Allows compilation when target Julia binary isn't runnable on host
- **Requires explicit path** via `-d:JuliaPath` or `JULIA_PATH` environment variable

### Example: Compiling for ARM64 Linux from x86_64 macOS

```bash
# Install ARM64 Julia libraries in a known location
export JULIA_PATH=/path/to/arm64-julia

# Cross-compile with Nim
nim c -d:nimjl_cross_compile \
     --cpu:arm64 \
     --os:linux \
     -d:JuliaPath="/path/to/arm64-julia" \
     myapp.nim
```

### Validation

To validate cross-compilation worked correctly:

1. **Check library dependencies**:
   ```bash
   # On Linux:
   ldd myapp | grep julia
   # On macOS:
   otool -L myapp | grep julia
   ```
   Should show paths to the correct Julia libraries

2. **Verify architecture**:
   ```bash
   # On Linux:
   file myapp
   # On macOS:
   lipo -info myapp
   ```
   Should show the target architecture (e.g., ARM64, x86_64)

3. **Check embedded version**:
   ```bash
   strings myapp | grep "Nimjl> Using"
   ```
   Should show the Julia version extracted from the library

4. **Runtime test**:
   Transfer the binary to the target platform and run it. If Julia initialization succeeds, the cross-compilation worked correctly.

## Debugging

* Most error will come from incorrect type passed between Julia and Nim. Check function interface and return type first.

* If you have random segfault that are non-reproductible, that may be a cause of the Julia GC cleaning memory that Nim uses. Consider using jlGcRoot.

* If you do not work with fixed version package for Julia, you are at risk of code breaking when packages are updated / upgraded.


# License

This project is released under MIT License.
