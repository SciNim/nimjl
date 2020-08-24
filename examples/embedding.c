#include "julia.h"
#include "stdio.h"

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.
jl_value_t *checked_eval_string(const char *code)
{
  jl_value_t *result = jl_eval_string(code);
  if (jl_exception_occurred())
  {
    // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
    jl_call2(jl_get_function(jl_base_module, "showerror"),
             jl_stderr_obj(),
             jl_exception_occurred());
    jl_printf(jl_stderr_stream(), "\n");
    // jl_atexit_hook(1);
    exit(1);
  }
  assert(result && "Missing return value but no exception occurred!");
  return result;
}

void simple_eval_string()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  // jl_init();
  // run Julia commands
  jl_value_t *ret1 = jl_eval_string("println(sqrt(2.0))");
  printf("ret1 = %p (should be nil)\n", ret1);
  // jl_atexit_hook(0);
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

void simple_call()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  // jl_init();
  {
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    jl_value_t *argument = jl_box_float64(2.0);
    jl_value_t *ret = jl_call1(func, argument);
    double cret = jl_unbox_float64(ret);
    printf("cret=%f \n", cret);
  }
  {
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    jl_value_t *argument = jl_box_float64(4.0);
    jl_value_t *ret = jl_call(func, (jl_value_t **)&argument, 1);
    double cret = jl_unbox_float64(ret);
    printf("cret=%f \n", cret);
  }
  // jl_atexit_hook(0);
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

void arrays_1D()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  // // jl_init();

  jl_value_t *array_type = jl_apply_array_type((jl_value_t *)jl_float64_type, 1);
  jl_array_t *x = jl_alloc_array_1d(array_type, 10);
  // JL_GC_PUSH* is required here to ensure that `x` is not deleted before
  // (aka, is gc-rooted until) the program reaches the corresponding JL_GC_POP()
  JL_GC_PUSH1(&x);

  double *xData = jl_array_data(x);

  size_t i;
  for (i = 0; i < jl_array_len(x); i++)
    xData[i] = i;

  jl_function_t *func = jl_get_function(jl_base_module, "reverse!");
  jl_value_t *ret = jl_call(func, (jl_value_t **)&x, 1);

  printf("x = [");
  for (i = 0; i < jl_array_len(x); i++)
    printf("%f ", xData[i]);
  printf("]\n");

  printf("size_t %li = jl_array_len(x)\n", jl_array_len((jl_value_t *)x));
  printf("rank %i = jl_array_rank(x) \n", jl_array_rank((jl_value_t *)x));
  printf("jl_array_dim(x, 0) = %li \n", jl_array_dim(x, 0));
  printf("jl_array_dim(x, 1) = %li \n", jl_array_dim(x, 1));

  JL_GC_POP();

  double *retData = jl_array_data(ret);
  printf("retData = [");
  for (i = 0; i < jl_array_len(x); i++)
    printf("%f ", xData[i]);
  printf("]\n");

  printf("\n");
  // jl_atexit_hook(0);
  printf("%s -- END \n\n", __FUNCTION__);
  return;
}

void arrays_2D()
{
  printf("%s -- BEGIN \n", __FUNCTION__);
  // jl_init();
  // 2D arrays
  double xData[5][5];
  for (int i = 0; i < 5; ++i)
  {
    for (int j = 0; j < 5; ++j)
    {
      xData[i][j] = 5 * i + j;
    }
  }

  printf("x = [");
  for (int i = 0; i < 5; ++i)
  {
    printf("[ ");
    for (int j = 0; j < 5; ++j)
    {
      printf("%f ", xData[i][j]);
    }
    printf("]");
  }
  printf("]\n");

  jl_value_t *array_type = jl_apply_array_type((jl_value_t *)jl_float64_type, 2);
  jl_value_t *dims = jl_eval_string("(5, 5)");
  jl_array_t *x = jl_ptr_to_array(array_type, xData, dims, 0);

  printf("size_t %li = jl_array_len(x)\n", jl_array_len((jl_value_t *)x));
  printf("rank %i = jl_array_rank(x) \n", jl_array_rank((jl_value_t *)x));

  printf("jl_array_dim(x, 0) = %li \n", jl_array_dim(x, 0));
  printf("jl_array_dim(x, 1) = %li \n", jl_array_dim(x, 1));

  jl_function_t *func = jl_get_function(jl_base_module, "rot180");
  if (!func)
  {
    printf("func is NULL\n");
    assert(0);
  }
  jl_value_t *res = jl_call(func, (jl_value_t **)&x, 1);
  double *resData = jl_array_data(res);

  printf("jl_array_dim(res, 0) = %li \n", jl_array_dim(res, 0));
  printf("jl_array_dim(res, 1) = %li \n", jl_array_dim(res, 1));

  printf("resData = [");
  for (int i = 0; i < 5; ++i)
  {
    printf("[ ");
    for (int j = 0; j < 5; ++j)
    {
      printf("%f ", resData[5 * i + j]);
    }
    printf("]");
  }
  printf("]\n");
  printf("\n");
  // jl_atexit_hook(0);
  printf("%s -- END \n\n", __FUNCTION__);
  return;
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
  external_module_squareMeBaby_3D();
  external_module_squareMeBaby();
  external_module_mutateMeByTen();
  return;
}

int main(int argc, char *argv[])
{
  jl_init();
  simple_eval_string();
  simple_call();
  arrays_1D();
  arrays_2D();
  external_module();
  jl_atexit_hook(0);
}
