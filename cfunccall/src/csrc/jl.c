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
  return jl_symbol(name);
}
//
jl_function_t *nimjl_get_function(jl_module_t *module, const char *name)
{
  return jl_get_function(module, name);
}

jl_value_t* nimjl_get_global(jl_module_t *module, char *name) {
  return jl_get_global(module, jl_symbol(name));
}

void *get_cfunction_pointer(const char *name)
{
    void *p = 0;
    jl_value_t *boxed_pointer = jl_get_global(jl_main_module, jl_symbol(name));
    if (boxed_pointer != 0) {
        p = jl_unbox_voidpointer(boxed_pointer);
    }
    if (!p) {
        fprintf(stderr, "cfunction pointer %s not available.\n", name);
    }
    return p;
}

void callAddMeBabyInt() {
  int (*addMe)(int, int);
  addMe = get_cfunction_pointer("julia_addMeBabyInt");
  int res = addMe(3, 4);
  printf("Calling from C says : %i \n", res);
}

// TODO : Do we need the sym ?
// jl_value_t* nimjl_get_global(jl_module_t *module, jl_sym_t *sym) {
//   return jl_get_global(module, sym)
// }
//

// ##################################
// Array type
// ##################################
jl_value_t *nimjl_apply_array_type_int8(size_t dim)
{
  return jl_apply_array_type(jl_int8_type, dim);
}

jl_value_t *nimjl_apply_array_type_int16(size_t dim)
{
  return jl_apply_array_type(jl_int16_type, dim);
}

jl_value_t *nimjl_apply_array_type_int32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_int32_type, dim);
}

jl_value_t *nimjl_apply_array_type_int64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_int64_type, dim);
}

jl_value_t *nimjl_apply_array_type_uint8(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint8_type, dim);
}

jl_value_t *nimjl_apply_array_type_uint16(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint16_type, dim);
}

jl_value_t *nimjl_apply_array_type_uint32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint32_type, dim);
}

jl_value_t *nimjl_apply_array_type_uint64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_uint64_type, dim);
}

jl_value_t *nimjl_apply_array_type_float32(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_float32_type, dim);
}

jl_value_t *nimjl_apply_array_type_float64(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_float64_type, dim);
}

jl_value_t *nimjl_apply_array_type_bool(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_bool_type, dim);
}

jl_value_t *nimjl_apply_array_type_char(size_t dim)
{
  return jl_apply_array_type((jl_value_t *)jl_char_type, dim);
}

// ##################################
// Array Utils
// ##################################
void *nimjl_array_data(jl_array_t *a)
{
  return jl_array_data(a);
}

int nimjl_array_dim(jl_array_t *a, int dim)
{
  return jl_array_dim(a, dim);
}

int nimjl_array_len(jl_array_t *a)
{
  return jl_array_len(a);
}

int nimjl_array_rank(jl_array_t *a)
{
  return jl_array_rank(a);
}

jl_array_t *nimjl_new_array(jl_value_t *atype, jl_value_t *dims)
{
  return nimjl_new_array(atype, dims);
}

jl_array_t *nimjl_reshape_array(jl_value_t *atype, jl_array_t *data, jl_value_t *dims)
{
  return jl_reshape_array(atype, data, dims);
}

jl_array_t *nimjl_ptr_to_array(jl_value_t *atype, void *data, jl_value_t *dims, int own_buffer)
{
  return jl_ptr_to_array(atype, data, dims, own_buffer);
}
