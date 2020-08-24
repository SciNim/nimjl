# Nim-Julia bridge 

This is repo is a WIP to be able to call Julia function from Nim using the C-API of Julia.

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

* Segfault arises when trying to return value from Julia function. While it should be doable in theory, I haven't figured it why / when it occurs yet. Best workaround is to work modifying in-place parameters. 
* Wrap using external Julia module
* Wrap using tuples from Nim named varargs or object
* Wrap proc for sequence / Tensor to nijl_array & nimjl_array to seq / Tensor conversion
* Macro that wrap box / unbox API
* Macro for calling julia function without intermediate code

## Next steps 

* Julia Tuples using C-API (no eval_string)
* Pass complex struct / object from Nim to Julia & vice-versa