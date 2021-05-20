import ./private/jlgc

proc jlGcCollect*() =
  jl_gc_collect(jlGcFull)

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

