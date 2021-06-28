Changelog for Nimjl. Date in format YYYY_MM_DD

Release v0.5.4 - 2021_XX_XX
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
* Tess suite and memory leak suite
