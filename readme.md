# Nim-Julia bridge 

This is repo is a WIP to be able to call Julia function from Nim using the C-API of Julia.

## Known limitation 

* Segfault arises when trying to return value from Julia function. While it should be doable in theory, I haven't figured it why / when it occurs yet. Best workaround is to work modifying in-place parameters. 

This issues is actually blocking because any Julia code that allocate in dependency could crash (I've had crashes using ` typeof` or function like that).
The header C Julia is not very well organized and not fit for automatic binding generation so everything has to be done & tested by hand.
It is stated in Julia v1.6 roadmap to clean the header C so I may wait for 1.6 (unless I figure out the problem).

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

* [ ] Fix memory problem that causes a crash in Julia GC. This problem also arises in the pure C example so it's not Nim related. It occurs when trying to return Array of different rank from the same successive call of a Julia function. It can occurs when using typeof on a 3-D Array and using JL_GC_PUSH(&args)
 doesn't fix it. 
 
 
## Next steps 

* Julia Tuples using C-API (no eval_string)
* Pass complex struct / object from Nim to Julia & vice-versa
* Generate the wrapper using c2nim / nimterop
