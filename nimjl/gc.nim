import config

## GC Functions to root
## Must be inline
type
  JlGcCollection {.pure, size: sizeof(cint), importc: "jl_gc_collection_t", header: JuliaHeader.} = enum
    jlGcAuto = 0 # JL_GC_AUTO
    jlGcFull = 1 # JL_GC_FULL
    jlGcIncremental = 2 # JL_GC_INCREMENTAL

{.push dynlib: JuliaLibName, header: JuliaHeader.}
## Force gc to run on everything
proc jlGcCollect*(v: JlGcCollection) {.importc: "jl_gc_collect".}
proc jlGcEnable*(toggle: cint): cint {.importc: "jl_gc_enable".}
proc jlGcIsEnabled*(): cint {.importc: "jl_gc_is_enabled".}
{.pop.}

proc jlGcCollect*() =
  jl_gc_collect(jlGcFull)

## Inline is really important here for stack preservation
{.push nodecl, inline, dynlib: JuliaLibName, header: JuliaHeader.}
proc julia_gc_push1*(a: pointer) {.importc: "JL_GC_PUSH1".}

proc julia_gc_push2*(a: pointer, b: pointer) {.importc: "JL_GC_PUSH2".}

proc julia_gc_push3*(a: pointer, b: pointer, c: pointer) {.importc: "JL_GC_PUSH3".}

proc julia_gc_push4*(a: pointer, b: pointer, c: pointer, d: pointer) {.importc: "JL_GC_PUSH4".}

proc julia_gc_push5*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer) {.importc: "JL_GC_PUSH5".}

proc julia_gc_push6*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer, f: pointer) {.importc: "JL_GC_PUSH6".}

# This one is even weirder : TODO document
proc julia_gc_pushargs*(a: pointer, n: csize_t) {.importc: "JL_GC_PUSHARGS".}

proc julia_gc_pop*() {.importc: "JL_GC_POP".}

{.pop.}

# Make it easier to not lose the scope
template jlGcRoot*(a: pointer, body: untyped) =
  if a.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push1(a.unsafeAddr())
    body
    julia_gc_pop()

template jlGcRoot*(a: pointer, b: pointer, body: untyped) =
  if a.isNil() or not b.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push2(a.unsafeAddr(), b.unsafeAddr())
    body
    julia_gc_pop()

template jlGcRoot*(a: pointer, b: pointer, c: pointer, body: untyped) =
  if a.isNil() or b.isNil() or c.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push3(a.unsafeAddr(), b.unsafeAddr(), c.unsafeAddr())
    body
    julia_gc_pop()

template jlGcRoot*(a: pointer, b: pointer, c: pointer, d: pointer, body: untyped) =
  if a.isNil() or b.isNil() or c.isNil() or d.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push4(a.unsafeAddr(), b.unsafeAddr(), c.unsafeAddr(), d.unsafeAddr())
    body
    julia_gc_pop()

template jlGcRoot*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer, body: untyped) =
  if a.isNil() or b.isNil() or c.isNil() or d.isNil() or e.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push5(a.unsafeAddr(), b.unsafeAddr(), c.unsafeAddr(), d.unsafeAddr(), e.unsafeAddr())
    body
    julia_gc_pop()

template jlGcRoot*(a: pointer, b: pointer, c: pointer, d: pointer, e: pointer, f: pointer, body: untyped) =
  if a.isNil() or b.isNil() or c.isNil() or d.isNil() or e.isNil() or f.isNil():
    raise newException(ValueError, "Julia cannot gc-root Nil values",)
  else:
    julia_gc_push6(a.unsafeAddr(), b.unsafeAddr(), c.unsafeAddr(), d.unsafeAddr(), e.unsafeAddr(), f.unsafeAddr())
    body
    julia_gc_pop()

