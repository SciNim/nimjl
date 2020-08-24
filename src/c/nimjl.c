// #define JULIA_ENABLE_THREADING 1
#include <stdio.h>
#include <julia.h>

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

// eval
void nimjl_init() { jl_init(); }
void nimjl_atexit_hook(int code) { jl_atexit_hook(code); }

// eval_string
// jl_value_t *nimjl_eval_string(char *code) { return jl_eval_string(code); }

// box & unbox
uint8_t nimjl_unbox_uint8(jl_value_t *value) { return jl_unbox_uint8(value); }
uint16_t nimjl_unbox_uint16(jl_value_t *value) { return jl_unbox_uint16(value); }
uint32_t nimjl_unbox_uint32(jl_value_t *value) { return jl_unbox_uint32(value); }
uint64_t nimjl_unbox_uint64(jl_value_t *value) { return jl_unbox_uint64(value); }

int8_t nimjl_unbox_int8(jl_value_t *value) { return jl_unbox_int8(value); }
int16_t nimjl_unbox_int16(jl_value_t *value) { return jl_unbox_int16(value); }
int32_t nimjl_unbox_int32(jl_value_t *value) { return jl_unbox_int32(value); }
int64_t nimjl_unbox_int64(jl_value_t *value) { return jl_unbox_int64(value); }

float nimjl_unbox_float32(jl_value_t *value) { return jl_unbox_float32(value); }
double nimjl_unbox_float64(jl_value_t *value) { return jl_unbox_float64(value); }

jl_value_t *nimjl_box_uint8(uint8_t value) { return jl_box_uint8(value); }
jl_value_t *nimjl_box_uint16(uint16_t value) { return jl_box_uint16(value); }
jl_value_t *nimjl_box_uint32(uint32_t value) { return jl_box_uint32(value); }
jl_value_t *nimjl_box_uint64(uint64_t value) { return jl_box_uint64(value); }

jl_value_t *nimjl_box_int8(int8_t value) { return jl_box_int8(value); }
jl_value_t *nimjl_box_int16(int16_t value) { return jl_box_int16(value); }
jl_value_t *nimjl_box_int32(int32_t value) { return jl_box_int32(value); }
jl_value_t *nimjl_box_int64(int64_t value) { return jl_box_int64(value); }

jl_value_t *nimjl_box_float32(float value) { return jl_box_float32(value); }
jl_value_t *nimjl_box_float64(double value) { return jl_box_float64(value); }

// Call function
// jl_function_t *nimjl_get_function(jl_module_t *module, const char *name)
// {
//   return jl_get_function(module, name);
// }

// jl_value_t *nimjl_call(jl_function_t *f, jl_value_t **args, int32_t nargs)
// {
//   return jl_call(f, args, nargs);
// }

// jl_value_t *nimjl_call0(jl_function_t *f)
// {
//   return jl_call0(f);
// }

// jl_value_t *nimjl_call1(jl_function_t *f, jl_value_t *args1)
// {
//   return jl_call1(f, args1);
// }

// jl_value_t *nimjl_call2(jl_function_t *f, jl_value_t *args1, jl_value_t *args2)
// {
//   return jl_call2(f, args1, args2);
// }

// jl_value_t *nimjl_call3(jl_function_t *f, jl_value_t *args1, jl_value_t *args2, jl_value_t *args3)
// {
//   return jl_call3(f, args1, args2, args3);
// }

// Array
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

jl_array_t *nimjl_ptr_to_array_1d(jl_value_t *atype, void *data, size_t nel, int own_buffer)
{
  return jl_ptr_to_array_1d(atype, data, nel, own_buffer);
}

jl_array_t *nimjl_ptr_to_array(jl_value_t *atype, void *data, jl_value_t *dims, int own_buffer)
{
  return jl_ptr_to_array(atype, data, dims, own_buffer);
}

jl_array_t *nimjl_alloc_array_1d(jl_value_t *atype, size_t nr)
{
  return jl_alloc_array_1d(atype, nr);
}

jl_array_t *nimjl_alloc_array_2d(jl_value_t *atype, size_t nr, size_t nc)
{
  return jl_alloc_array_2d(atype, nr, nc);
}

jl_array_t *nimjl_alloc_array_3d(jl_value_t *atype, size_t nr, size_t nc, size_t z)
{
  return jl_alloc_array_3d(atype, nr, nc, z);
}
// Array type
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

void nimjl_gc_push1(void *a)
{
  JL_GC_PUSH1(a);
}

void nimjl_gc_push2(void *a, void *b)
{
  JL_GC_PUSH2(a, b);
}

void nimjl_gc_push3(void *a, void *b, void *c)
{
  JL_GC_PUSH3(a, b, c);
}

void nimjl_gc_push4(void *a, void *b, void *c, void *d)
{
  JL_GC_PUSH4(a, b, c, d);
}

void nimjl_gc_push5(void *a, void *b, void *c, void *d, void *e)
{
  JL_GC_PUSH5(a, b, c, d, e);
}
void nimjl_gc_push6(void *a, void *b, void *c, void *d, void *e, void *f)
{
  JL_GC_PUSH6(a, b, c, d, e, f);
}

void nimjl_gc_pushargs(jl_value_t **a, size_t n)
{
  JL_GC_PUSHARGS(a, n);
}

void nimjl_gc_pop()
{
  JL_GC_POP();
}

jl_value_t *nimjl_exception_occurred()
{
  return jl_exception_occurred();
}

char *nimjl_typeof_str(jl_value_t *v)
{
  return jl_typeof_str(v);
}

char *nimjl_string_ptr(jl_value_t *v)
{
  return jl_string_ptr(v);
}

jl_array_t *nimjl_make_array(void *existingArray, int ndims, int *dimsArray)
{
  printf("%s \n", __func__);
  jl_value_t *array_type = jl_apply_array_type((jl_value_t *)jl_float64_type, 3);
  char strDimsBuf[12];
  snprintf(strDimsBuf, 12, "(%i, %i, %i)", dimsArray[0], dimsArray[1], dimsArray[2]);

  printf("%s \n", strDimsBuf);
  jl_value_t *dims = jl_eval_string(strDimsBuf);
  jl_array_t *xArray = jl_ptr_to_array(array_type, existingArray, dims, 0);
  return xArray;
}
jl_array_t *nimjl_make_2d_array(void *existingArray, int *dimsArray)
{
  printf("%s \n", __func__);
  jl_value_t *array_type = jl_apply_array_type((jl_value_t *)jl_float64_type, 2);
  char strDimsBuf[12];
  snprintf(strDimsBuf, 12, "(%i, %i)", dimsArray[0], dimsArray[1]);
  printf("%s \n", strDimsBuf);

  jl_value_t *dims = jl_eval_string(strDimsBuf);
  jl_array_t *xArray = jl_ptr_to_array(array_type, existingArray, dims, 0);
  return xArray;
}

jl_array_t *nimjl_make_3d_array(void *existingArray, int *dimsArray)
{
  printf("%s \n", __func__);
  jl_value_t *array_type = jl_apply_array_type((jl_value_t *)jl_float64_type, 3);
  char strDimsBuf[12];
  snprintf(strDimsBuf, 12, "(%i, %i, %i)", dimsArray[0], dimsArray[1], dimsArray[2]);

  printf("%s \n", strDimsBuf);
  jl_value_t *dims = jl_eval_string(strDimsBuf);
  jl_array_t *xArray = jl_ptr_to_array(array_type, existingArray, dims, 0);
  return xArray;
}

static void external_module_dummy()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  {
    printf("dummy \n");
    // Call easy function
    jl_module_t *custom_module = (jl_module_t *)jl_eval_string("custom_module");
    jl_function_t *dummy = jl_get_function(custom_module, "dummy");
    if (dummy != NULL)
    {
      printf("dummy is not null\n");
    }
    else
    {
      printf("dummy is null\n");
      return;
    }
    jl_call0(dummy);
  }
  printf("\n");
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

static jl_value_t* external_module_squareMeBaby_3D()
{
    printf("%s -- BEGIN \n", __func__);
    jl_module_t *custom_module = (jl_module_t *)jl_eval_string("custom_module");
    jl_function_t *func = jl_get_function(custom_module, "squareMeBaby");

    if (func != NULL)
    {
      printf("squareMeBaby is not Null\n");
    }
    else
    {
      printf("squareMeBaby is null\n");
    }
    printf("%s -> make_array \n", __func__);
    double existingArray0[3][4][5]; 
    int length = 3*4*5;
    int dimsArray[3];
    dimsArray[0] = 3;
    dimsArray[1] = 4;
    dimsArray[2] = 5;
    jl_array_t* xArray = nimjl_make_3d_array(existingArray0, dimsArray);

    double *xData = (double *)jl_array_data(xArray);
    for (int i = 0; i < length; i++)
      xData[i] = i / 3.0;

    jl_value_t *ret = jl_call1(func, (jl_value_t *)xArray);
    printf("%s -> call done \n", __func__);
    if (!ret)
    {
      printf("ret is %p \n\n", ret);
    }
    {
      printf("len(ret)=%li \n", jl_array_len(ret));
      printf("rank %i = jl_array_rank(x) \n", jl_array_rank((jl_value_t *)ret));
      int d1 = jl_array_dim(ret, 0);
      int d2 = jl_array_dim(ret, 1);

      double *xResult = jl_array_data(ret);
      printf("xResult = [");
      for (int i = 0; i < d1; i++)
        for (int j = 0; j < d2; j++)
          printf("%lf ", xResult[i * d2 + j]);
      printf("]\n");
    }
    printf("%s -- END \n", __func__);
    return ret;
} 


static void external_module_squareMeBaby()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  {
    printf("\nsquareMeBaby \n");
    jl_module_t *custom_module = (jl_module_t *)jl_eval_string("custom_module");
    jl_function_t *func = jl_get_function(custom_module, "squareMeBaby");

    if (func != NULL)
    {
      printf("squareMeBaby is not Null\n");
    }
    else
    {
      printf("squareMeBaby is null\n");
      return;
    }

    // create a 2D array of length 30
    double length = 5 * 6;
    double *existingArray = (double *)malloc(sizeof(double) * length);

    int dims[3];
    dims[0] = 5;
    dims[1] = 6;
    jl_array_t* xArray = nimjl_make_2d_array(existingArray, dims);

    // fill in values
    double *xData = (double *)jl_array_data(xArray);
    for (int i = 0; i < length; i++)
      xData[i] = i;

    {
      int d1 = jl_array_dim(xArray, 0);
      int d2 = jl_array_dim(xArray, 1);
      int len = jl_array_len(xArray);

      printf("dims(xArray, 0) = %i, dims(xArray, 1) = %i \n", d1, d2);
      printf("len(xArray)=%i \n", len);
    };

    printf("\n");
    jl_value_t *ret = jl_call1(func, (jl_value_t *)xArray);
    if (!ret)
    {
      printf("ret is %p \n\n", ret);
      return;
    }
    {
      printf("len(ret)=%li \n", jl_array_len(ret));
      printf("rank %i = jl_array_rank(x) \n", jl_array_rank((jl_value_t *)ret));
      int d1 = jl_array_dim(ret, 0);
      int d2 = jl_array_dim(ret, 1);

      double *xResult = jl_array_data(ret);
      printf("xResult = [");
      for (int i = 0; i < d1; i++)
        for (int j = 0; j < d2; j++)
          printf("%lf ", xResult[i * d2 + j]);
      printf("]\n");
    }
    free(existingArray);
  }
  printf("\n");
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

static void external_module_mutateMeByTen()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  // required: setup the Julia context
  {
    printf("\nmutateMeByTen\n");
    jl_module_t *custom_module = (jl_module_t *)jl_eval_string("custom_module");
    jl_function_t *func = jl_get_function(custom_module, "mutateMeByTen!");

    if (func != NULL)
    {
      printf("mutateMeByTen is not Null\n");
    }
    else
    {
      printf("mutateMeByTen is null\n");
      return;
    }

    int d1 = 3;
    int d2 = 4;
    int d3 = 5;
    double length = d1 * d2 * d3;
    double existingArray[3][4][5];

    int dims[3];
    dims[0] = d1;
    dims[1] = d2;
    dims[2] = d3;

    jl_array_t* xArray = nimjl_make_3d_array(existingArray, dims);

    // fill in values
    double *xData = (double *)jl_array_data(xArray);
    int index = 0;
    for(int i = 0; i<length; i++)
    {
      xData[i] = (double)((++index)/2.0);
    }

    for (int i = 0; i < d1; i++)
    {
      for (int j = 0; j < d2; j++)
      {
        for (int k = 0; k < d3; k++)
        {
          int arrayIdx = k + d2 * (j + d1 * i);
          double d = xData[arrayIdx];
          printf("%lf ", d);
        }
      }
    }
    printf("\n");

    jl_value_t *ret = jl_call1(func, (jl_value_t *)xArray);
    if (!ret)
    {
      printf("ret is %p \n\n", ret);
      return;
    }
    {
      int d1 = jl_array_dim(xArray, 0);
      int d2 = jl_array_dim(xArray, 1);
      int d3 = jl_array_dim(xArray, 2);
      int len = jl_array_len(xArray);

      printf("%i %i %i \n", d1, d2, d3);
      printf("len(ret)=%i \n", len);

      for (int i = 0; i < d1; i++)
      {
        for (int j = 0; j < d2; j++)
        {
          for (int k = 0; k < d3; k++)
          {
            int arrayIdx = k + d2 * (j + d1 * i);
            double d = xData[arrayIdx];
            printf("%lf ", d);
          }
        }
      }
      printf("\n");
    }
  }
  printf("\n");
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

void external_module()
{
  jl_eval_string("include(\"test.jl\")");
  jl_eval_string("using .custom_module");
  external_module_dummy();
  external_module_squareMeBaby();
  external_module_mutateMeByTen();
  external_module_squareMeBaby_3D();
  // return;
}
