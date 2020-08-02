# Nim-Julia bridge 

This is repo is a WIP.

You may need to update your Julia installation location in the Makefile.
This is a WIP so far only the makefile and embedding.nim are relevant.

# Prerequisite

You need to setup an envinronment variable called `JULIA_PATH` pointing to the parent folder of Julia.
For example, on Linux you can add this to your `.bashrc` :
```
export JULIA_PATH=~/julia-1.4.2
```

## Ressources

How to embed Julia w/ C :

* https://docs.julialang.org/en/v1/manual/embedding/index.html#Working-with-Arrays-1

* https://github.com/JuliaLang/julia/tree/master/test/embedding

## TODO List

* Tuples API
* Pass complex struct / object from Nim to Julia & vice-versa
* Wrap proc for sequence / Tensor to nijl_array & nimjl_array to seq / Tensor conversion
* Macro that wrap box / unbox API
* Wrap using external Julia module
* Macro for calling julia function without intermediate code