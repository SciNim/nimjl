Changelog for Nimjl. Date in format YYYY_MM_DD

Release v0.9.0 - 2026_01_24 (Planned)
===========================
* Enhanced error handling with custom exceptions (JlError, JlInitError) and Julia stack traces
* System image support for faster startup via precompiled Julia environments
* Compile-time Julia code embedding (no external .jl files needed for deployment)
* Extended Julia C API bindings (module operations, type checking, threading, GC control)
* Cross-compilation support: compile for different architectures without target Julia binary
* macOS support: proper .dylib detection and rpath handling
* C++ backend compatibility: Nim-side initialization tracking prevents pre-dylib segfaults
* Refactored architecture: C bindings in private/, implementation modules properly organized
* Platform validation for system image support (Linux, macOS, Windows)
* New examples: ex13 (error handling), ex14 (system images), ex15 (embedded code)

Release v0.8.2 - 2024_03_27
===========================
* Repo moved to SciNim
* Added activate option in init to start-up Julia in a virtual environment
* Added Hook function at init to execute code : BEFORE jl_init() is called; AFTER jl_init() and Pkg.activate() is called but BEFORE Pkg.add calls and BEFORE the embedded code is passed through ``eval`` function.
* Order of update is now relevant
* Updated readme and examples

Release v0.8.1 - 2023_09_30
===========================
* Inexisting (nimble wasn't up to date when tagged)

Release v0.8.0 - 2023_09_30
===========================
* Clean-up some code
* Added more type in evaluation of Dict and Tuples
* Improve loading a Package at init when the Package is already present (speed up init phase)

Release v0.7.6 - 2023_02_22
===========================
* Small CI change

Release v0.7.5 - 2022_07_07
===========================
* Fixed https://github.com/Clonkk/nimjl/issues/18

Release v0.7.4 - 2022_06_08
===========================
* Improve Pkg template to handle version, url etc; parameters :
* See ex11
  ```nim
    Julia.init(1):
      Pkg:
        add(name="Polynomials", version="3.0.0")
        add(name="LinearAlgebra")
        add("DSP")
      Embed:
        file("myfile.jl")
  ```

Release v0.7.3 - 2022_01_04
===========================
* Bugfix related to JULIA_PATH not being defined

Release v0.7.2 - 2022_01_04
===========================
* Add nthreads argument to Julia.init() to start the Julia VM on multiple threads

Release v0.7.1 - 2022_01_04
===========================
* Normalize path during compilation
* Various docs improvements

Release v0.7.0 - 2022_01_04
===========================
* Add Julia.useModule alias for jlUseModule
* Add Julia.includeFile (include is reserved keyword) alias for jlInclude
* Add mechanism to embed julia files at compile-time and run the code at init for an easy way to distribute binary with Julia code contained
* Add Pkg template to easily install new Julia package during init ; it is also compatible with the embedding stuff :
* See ex09
  ```nim
    Julia.init:
      Pkg:
        add("LinearAlgebra")
      Embed:
        file("myfile.jl")
  ```

Release v0.6.3 - 2021_11_05
===========================
* Row major / col major handling when converting Arraymancer Tensor <-> JlArray

Release v0.6.2 - 2021_10_19
===========================
* Invert dot-like operators .+ -> +. to avoid dot-like operator

Release v0.6.1 - 2021_10_14
===========================
* pairs iterators for named Tuple

Release v0.6.0 - 2021_10_08
===========================
* Add --gc:orc to CI

Release v0.5.9 - 2021_10_05
===========================
* CI fix

Release v0.5.8 - 2021_09_29
===========================
* Renamed examples so it's easier to read in order

Release v0.5.7 - 2021_08_16
===========================
* Added dot operators and broadcast mechanism.
* Added JlDataType conversions to typedesc
* Added ``rand`` proc to initialize Julia Array
* Updated tests

Release v0.5.6 - 2021_07_23
===========================
* Julia.Exit() now made optinnal
* Fixed indexing bugs. Factorized some code.

Release v0.5.5 - 2021_07_15
===========================
* Updated nimble file for Nim >= 1.4.0 (pre-1.4.0 will not work)
* Updated CI to add MacOs in test Matrix; Next is adding windows but I need to link for Windows

Release v0.5.4 - 2021_07_01
===========================
* Added field access syntax with `.` and moved call syntax to `.()`
* lent for `[]`
* Fix issues on object <=> struct vonersions (notably with Option[T])
* Added common / useful procs directly accessible

Release v0.5.3 - 2021_06_24
===========================
* Improve file layout
* Added object <=> struct conversions

Release v0.5.2 - 2021_05_25
===========================
* Split tests into multiple files
* Add fill, asType proc for arrays

Release v0.5.1 - 2021_05_21
===========================
* Added some operators
* Added support for iterators
* Added toJlValue as an alias to toJlVal for consistency
* Added indexing syntax
* Added swapMemoryOrder for col major vs row major

Release v0.5.0 - 2021_05_19
===========================
* Add Nim interop syntax
* Started work on indexing Julia Arrays natively

Release v0.4.5 - 2021_04_02
===========================
* Fixed char* / const char* with clang issue
* Fixed enum for jlGcCollect not being properly defined
* Add flags to run valgrind and msan if need be

Release v0.4.4 - 2021_03_25
===========================
* Add support for Option
* Fix boxing bool and voidpointer types
* Improve test coverage
* Add examples to ci

Release v0.4.3 - 2021_03_22
===========================
* Add CI

Release v0.4.2 - 2021_03_18
===========================
* Add support for nested objects
* Use {.push header:juliaHeader.} when necessary

Release v0.4.1 - 2021_03_10
===========================
* Add seq support when converting types
* Add Tensor support when converting types
* Improved dispatch using generic proc instead of ``when T is ...``
* Format code using nimpretty
* Add changelog
* Improve readme
* Improve examples

Release v0.4.0 - 2021_03_08
===========================
* First official release
* Support Arrays / Tuple / Dict of POD
* Supports Julia Arrays from Buffer.
* Add ``toJlVal`` / ``to`` proc to make conversion betwen Julia types and Nim types "smooth"
* Added Julia exception handler from Nim
* Examples in the examples folder
* Test suite and memory leak suite
