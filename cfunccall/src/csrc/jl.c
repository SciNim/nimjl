// #define JULIA_ENABLE_THREADING 1
#include <stdio.h>
#include <julia.h>

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

// eval
void nimjl_init() { jl_init(); }
void nimjl_gc_enable(int toggle) { jl_gc_enable(toggle); }
void nimjl_atexit_hook(int code) { jl_atexit_hook(code); }

// eval_string
jl_value_t *nimjl_eval_string(char *code)
{
  return jl_eval_string(code);
}
void* nimjl_unbox_voidpointer(jl_value_t* ptr)
{
  return jl_unbox_voidpointer(ptr);
}
jl_sym_t* nimjl_symbol(const char* name)
{
  // jl_sym_t *(*jl_symbol)(const char *);
  return jl_symbol(name);
}
//
jl_function_t *nimjl_get_function(jl_module_t *module, const char *name)
{
  return jl_get_function(module, name);
}

jl_value_t* nimjl_get_global(jl_module_t *module, const char *name) {
  return jl_get_global(module, jl_symbol(name))
}

// TODO : Do we need the sym ?
// jl_value_t* nimjl_get_global(jl_module_t *module, jl_sym_t *sym) {
//   return jl_get_global(module, sym)
// }

