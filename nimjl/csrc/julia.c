// #define JULIA_ENABLE_THREADING 1
#include <stdio.h>
#include <julia.h>

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

// eval
void jl_vm_init() { jl_init(); }
void jl_vm_atexit_hook(int code) { jl_atexit_hook(code); }
void julia_gc_enable(int toggle) { jl_gc_enable(toggle); }

// eval_string
jl_value_t *julia_eval_string(char *code) { return jl_eval_string(code); }

// Unbox func
uint8_t julia_unbox_uint8(jl_value_t *value) { return jl_unbox_uint8(value); }
uint16_t julia_unbox_uint16(jl_value_t *value) { return jl_unbox_uint16(value); }
uint32_t julia_unbox_uint32(jl_value_t *value) { return jl_unbox_uint32(value); }
uint64_t julia_unbox_uint64(jl_value_t *value) { return jl_unbox_uint64(value); }

int8_t julia_unbox_int8(jl_value_t *value) { return jl_unbox_int8(value); }
int16_t julia_unbox_int16(jl_value_t *value) { return jl_unbox_int16(value); }
int32_t julia_unbox_int32(jl_value_t *value) { return jl_unbox_int32(value); }
int64_t julia_unbox_int64(jl_value_t *value) { return jl_unbox_int64(value); }

float julia_unbox_float32(jl_value_t *value) { return jl_unbox_float32(value); }
double julia_unbox_float64(jl_value_t *value) { return jl_unbox_float64(value); }

// Box func
jl_value_t *julia_box_uint8(uint8_t value) { return jl_box_uint8(value); }
jl_value_t *julia_box_uint16(uint16_t value) { return jl_box_uint16(value); }
jl_value_t *julia_box_uint32(uint32_t value) { return jl_box_uint32(value); }
jl_value_t *julia_box_uint64(uint64_t value) { return jl_box_uint64(value); }
jl_value_t *julia_box_int8(int8_t value) { return jl_box_int8(value); }
jl_value_t *julia_box_int16(int16_t value) { return jl_box_int16(value); }
jl_value_t *julia_box_int32(int32_t value) { return jl_box_int32(value); }
jl_value_t *julia_box_int64(int64_t value) { return jl_box_int64(value); }
jl_value_t *julia_box_float32(float value) { return jl_box_float32(value); }
jl_value_t *julia_box_float64(double value) { return jl_box_float64(value); }

// Call function
jl_function_t *julia_get_function(jl_module_t *module, const char *name)
{
  return jl_get_function(module, name);
}

jl_value_t *julia_call(jl_function_t *f, jl_value_t **args, int32_t nargs)
{
  return jl_call(f, args, nargs);
}

jl_value_t *julia_call0(jl_function_t *f)
{
  return jl_call0(f);
}

jl_value_t *julia_call1(jl_function_t *f, jl_value_t *args1)
{
  return jl_call1(f, args1);
}

jl_value_t *julia_call2(jl_function_t *f, jl_value_t *args1, jl_value_t *args2)
{
  return jl_call2(f, args1, args2);
}

jl_value_t *julia_call3(jl_function_t *f, jl_value_t *args1, jl_value_t *args2, jl_value_t *args3)
{
  return jl_call3(f, args1, args2, args3);
}

// Array
void *julia_array_data(jl_array_t *a)
{
  return jl_array_data(a);
}

int julia_array_dim(jl_array_t *a, int dim)
{
  return jl_array_dim(a, dim);
}

int julia_array_len(jl_array_t *a)
{
  return jl_array_len(a);
}

int julia_array_rank(jl_array_t *a)
{
  return jl_array_rank(a);
}

jl_array_t *julia_new_array(jl_value_t *atype, jl_value_t *dims)
{
  return julia_new_array(atype, dims);
}

jl_array_t *julia_reshape_array(jl_value_t *atype, jl_array_t *data, jl_value_t *dims)
{
  return jl_reshape_array(atype, data, dims);
}

jl_array_t *julia_ptr_to_array_1d(jl_value_t *atype, void *data, size_t nel, int own_buffer)
{
  return jl_ptr_to_array_1d(atype, data, nel, own_buffer);
}

jl_array_t *julia_ptr_to_array(jl_value_t *atype, void *data, jl_value_t *dims, int own_buffer)
{
  return jl_ptr_to_array(atype, data, dims, own_buffer);
}

jl_array_t *julia_alloc_array_1d(jl_value_t *atype, size_t nr)
{
  return jl_alloc_array_1d(atype, nr);
}

jl_array_t *julia_alloc_array_2d(jl_value_t *atype, size_t nr, size_t nc)
{
  return jl_alloc_array_2d(atype, nr, nc);
}

jl_array_t *julia_alloc_array_3d(jl_value_t *atype, size_t nr, size_t nc, size_t z)
{
  return jl_alloc_array_3d(atype, nr, nc, z);
}
// Array type
jl_value_t *julia_apply_array_type_int8(size_t dim)
{
  return jl_apply_array_type(jl_int8_type, dim);
}

jl_value_t *julia_apply_array_type_int16(size_t dim)
{
  return jl_apply_array_type(jl_int16_type, dim);
}

jl_value_t *julia_apply_array_type_int32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_int32_type, dim);
}

jl_value_t *julia_apply_array_type_int64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_int64_type, dim);
}

jl_value_t *julia_apply_array_type_uint8(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint8_type, dim);
}

jl_value_t *julia_apply_array_type_uint16(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint16_type, dim);
}

jl_value_t *julia_apply_array_type_uint32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint32_type, dim);
}

jl_value_t *julia_apply_array_type_uint64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint64_type, dim);
}

jl_value_t *julia_apply_array_type_float32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_float32_type, dim);
}

jl_value_t *julia_apply_array_type_float64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_float64_type, dim);
}

jl_value_t *julia_apply_array_type_bool(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_bool_type, dim);
}

jl_value_t *julia_apply_array_type_char(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_char_type, dim);
}

inline void julia_gc_collect() {
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

jl_value_t *julia_exception_occurred()
{
  return jl_exception_occurred();
}

char *julia_typeof_str(jl_value_t *v)
{
  return jl_typeof_str(v);
}

char *julia_string_ptr(jl_value_t *v)
{
  return jl_string_ptr(v);
}
