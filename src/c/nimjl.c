#include <julia.h>
#include <stdio.h>

JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

void nimjl_init() {jl_init();}
void nimjl_atexit_hook(int code) {nimjl_atexit_hook(code);}

jl_value_t* nimjl_eval_string(char* code) {jl_eval_string(code);}


uint8_t* nimjl_unbox_uint8 (jl_value_t* value) {jl_unbox_uint8(value);}
uint16_t* nimjl_unbox_uint16(jl_value_t* value) {jl_unbox_uint16(value);}
uint32_t* nimjl_unbox_uint32(jl_value_t* value) {jl_unbox_uint32(value);}
uint64_t* nimjl_unbox_uint64(jl_value_t* value) {jl_unbox_uint64(value);}

int8_t* nimjl_unbox_int8 (jl_value_t* value) {jl_unbox_int8(value);}
int16_t* nimjl_unbox_int16(jl_value_t* value) {jl_unbox_int16(value);}
int32_t* nimjl_unbox_int32(jl_value_t* value) {jl_unbox_int32(value);}
int64_t* nimjl_unbox_int64(jl_value_t* value) {jl_unbox_int64(value);}

float * nimjl_unbox_float32(jl_value_t* value) {jl_unbox_float32(value);}
double * nimjl_unbox_float64(jl_value_t* value) {jl_unbox_float64(value);}

jl_value_t* nimjl_box_uint8(uint8_t value) {jl_box_uint8(value);}
jl_value_t* nimjl_box_uint16(uint16_t value) {jl_box_uint16(value);}
jl_value_t* nimjl_box_uint32(uint32_t value) {jl_box_uint32(value);}
jl_value_t* nimjl_box_uint64(uint64_t value) {jl_box_uint64(value);}

jl_value_t* nimjl_box_int8(int8_t value) {jl_box_int8(value);}
jl_value_t* nimjl_box_int16(int16_t value) {jl_box_int16(value);}
jl_value_t* nimjl_box_int32(int32_t value) {jl_box_int32(value);}
jl_value_t* nimjl_box_int64(int64_t value) {jl_box_int64(value);}

jl_value_t* nimjl_box_float32(float value) {jl_box_float32(value);}
jl_value_t* nimjl_box_float64(double value) {jl_box_float64(value);}


jl_function_t *nimjl_get_function(const char *name) { return jl_get_function(jl_base_module, name);}
jl_value_t *nimjl_call(jl_function_t *f, jl_value_t **args, int32_t nargs) { jl_call(f, args, nargs);}


jl_array_t *nimjl_ptr_to_array(jl_value_t *atype, void *data, jl_value_t *dims, int own_buffer) {
  return jl_ptr_to_array(atype, data, dims, own_buffer);
}
void *nimjl_array_ptr(jl_array_t *a) {
  return jl_array_ptr(a);
}

#define jl_array_data(a)  ((void*)((jl_array_t*)(a))->data)
#define jl_array_dim(a,i) ((&((jl_array_t*)(a))->nrows)[i])

int nimjl_array_rank(jl_value_t *a) {
  return jl_array_rank(a);
}
size_t jl_array_size(jl_value_t *a, int d) {
  return jl_array_size(a, d);
}


  // jl_value_t *jl_call0(jl_function_t *f);
  // jl_value_t *jl_call1(jl_function_t *f, jl_value_t *a);
  // jl_value_t *jl_call2(jl_function_t *f, jl_value_t *a, jl_value_t *b);
  // jl_value_t *jl_call3(jl_function_t *f, jl_value_t *a, jl_value_t *b, jl_value_t *c);



