import config
import basetypes

##GC Functions
proc nimjl_gc_push1*(a: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_push2*(a: pointer, b: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_push3*(a: pointer, b: pointer, c: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_push4*(a: pointer, b: pointer, c: pointer, d: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_push5*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_push6*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer, f: pointer) {.cdecl, importc, inline.}

proc nimjl_gc_pushargs*(a: pointer, n: csize_t) {.cdecl, importc, inline.}

proc nimjl_gc_pop*() {.cdecl, importc, inline.}

proc nimjl_gc_collect*() {.cdecl, importc, inline.}

proc nimjl_gc_enable*(toggle: cint) {.cdecl, importc.}
