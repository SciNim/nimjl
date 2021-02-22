# Nim-Julia bridge 

This is repo is a WIP to be able to call Julia function from Nim using the C-API of Julia.

## Prerequisite

Run ``nimble install`` or ``nimble develop``

## Ressources

How to embed Julia w/ C :

* https://docs.julialang.org/en/v1/manual/embedding/index.html#Working-with-Arrays-1

* https://github.com/JuliaLang/julia/tree/master/test/embedding

## Next steps 

* Julia Tuples using C-API (no eval_string)
* Pass complex struct / object from Nim to Julia & vice-versa
* Handle row major vs column major transposition when using array
* Supports Windows 

## Limitations

* Arrays only supports POD data types (``SomeNumber`` types) 
* No Julia struct <-> Nim object conversion
* No proper (current way of converting is ugly) Nim tuple <-> Julia tuple conversion
* No tag tracing Julia memory allocation 

# Examples

TODO

# Documentation

TODO
