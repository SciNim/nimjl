# Nim-Julia bridge 

This is repo is a WIP to be able to call Julia function from Nim using the C-API of Julia.

## Prerequisite

* Have Julia installed 
* Set the environment variable JULIA_PATH to the Julia installation folder 
* Run ``nimble install`` or ``nimble develop`` 

## Ressources

How to embed Julia w/ C :

* https://docs.julialang.org/en/v1/manual/embedding/index.html#Working-with-Arrays-1

* https://github.com/JuliaLang/julia/tree/master/test/embedding

* ``legacy/`` folder contains previous experiment and examples of wrapping in C. 

* ``tests/testfull.nim`` contains several test suite and examples

## Next steps 

* Handle row major vs column major transposition when using array
* Tag tracing for Julia memory allocation 

## Limitations

* Only supports Linux for now
* Arrays only supports POD data types (``SomeNumber`` types) 
* Julia allocated arrays only goes up to 3 dimensions (but Arrays can be allocated in Nim)
* Value conversion Nim <==> Julia involves a copy unless using Julia Arrays allocated in Nim. 

# Examples

TODO

# Documentation

TODO
