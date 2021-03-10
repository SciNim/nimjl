Changelog for Nimjl. Date in format YYYY_MM_DD

Release v0.4.1 - 2021_XX_XX
===========================

* Add seq support when converting types
* Add Tensor support when converting types
* Improved dispatch using generic proc instead of ``when T is ...``
* Format code using nimpretty 
* Add changelog

Release v0.4.0 - 2021_08_03
===========================

* First official release
* Support Arrays / Tuple / Dict of POD
* Supports Julia Arrays from Buffer.
* Add ``toJlVal`` / ``to`` proc to make conversion betwen Julia types and Nim types "smooth"
* Added Julia exception handler from Nim
* Examples in the examples folder
* Tess suite and memory leak suite
