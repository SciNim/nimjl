#include <stdio.h>
#include <julia.h>

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

void julia_gc_enable(int toggle) { jl_gc_enable(toggle); }

void julia_gc_collect() {
  jl_gc_collect(JL_GC_FULL);
}

inline void julia_gc_push1(void *a)
{
  JL_GC_PUSH1(a);
}

inline void julia_gc_push2(void *a, void *b)
{
  JL_GC_PUSH2(a, b);
}

inline void julia_gc_push3(void *a, void *b, void *c)
{
  JL_GC_PUSH3(a, b, c);
}

inline void julia_gc_push4(void *a, void *b, void *c, void *d)
{
  JL_GC_PUSH4(a, b, c, d);
}

inline void julia_gc_push5(void *a, void *b, void *c, void *d, void *e)
{
  JL_GC_PUSH5(a, b, c, d, e);
}

inline void julia_gc_push6(void *a, void *b, void *c, void *d, void *e, void *f)
{
  JL_GC_PUSH6(a, b, c, d, e, f);
}

inline void julia_gc_pushargs(jl_value_t **a, size_t n)
{
  JL_GC_PUSHARGS(a, n);
}

inline void julia_gc_pop()
{
  JL_GC_POP();
}

