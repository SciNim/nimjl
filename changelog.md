Changelog for Nimjl. Date in format YYYY_MM_DD

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
