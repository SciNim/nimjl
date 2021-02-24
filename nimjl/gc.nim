import config


## GC Functions to root
## Must be inline
proc julia_gc_push1*(a: pointer) {.cdecl, importc:"julia_gc_push1", inline.}

proc julia_gc_push2*(a: pointer, b: pointer) {.cdecl, importc:"julia_gc_push2", inline.}

proc julia_gc_push3*(a: pointer, b: pointer, c: pointer) {.cdecl, importc:"julia_gc_push3", inline.}

proc julia_gc_push4*(a: pointer, b: pointer, c: pointer, d: pointer) {.cdecl, importc:"julia_gc_push4", inline.}

proc julia_gc_push5*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer) {.cdecl, importc:"julia_gc_push5", inline.}

proc julia_gc_push6*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer, f: pointer) {.cdecl, importc:"julia_gc_push6", inline.}

proc julia_gc_pushargs*(a: pointer, n: csize_t) {.cdecl, importc:"julia_gc_pushargs", inline.}

proc julia_gc_pop*() {.cdecl, importc:"julia_gc_pop", inline.}

## Force gc to run on everything
proc julia_gc_collect*() {.cdecl, importc, inline.}

## Disable / enable gc
proc julia_gc_enable*(toggle: cint) {.cdecl, importc.}
