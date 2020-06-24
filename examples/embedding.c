#include "julia.h"
#include "stdio.h"

JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

int main(int argc, char *argv[])
{
  /* required: setup the Julia context */
  printf("jl_init \n");
  jl_init();

  {
    printf("\neval_string \n");
    /* run Julia commands */
    jl_eval_string("print(sqrt(2.0))");
    printf("\n");
  }
  {
    printf("\njl_call1\n");
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    printf("%p \n", func);
    jl_value_t* argument = jl_box_float64(2.0);
    jl_value_t* ret = jl_call1(func, argument);
    double cret = jl_unbox_float64(ret);
    printf("cret=%f \n", cret);
    double retDouble = jl_unbox_float64(ret);
    printf("sqrt(2.0) in C: %e\n", retDouble);
  }
  {
    printf("\njl_call\n");
    /* test jl_call */
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    jl_value_t *argument = jl_box_float64(4.0);
    jl_value_t *ret = jl_call(func, (jl_value_t**)&argument, 1);
    int cret = jl_unbox_int32(ret);
    printf("cret=%i \n", cret);
    double cargs = jl_unbox_float64(argument);
    printf("cargs= %f \n", cargs);
  }
  {
    // 1D arrays
    printf("\n1D Array\n");

    jl_value_t* array_type = jl_apply_array_type((jl_value_t*)jl_float64_type, 1);
    jl_array_t* x          = jl_alloc_array_1d(array_type, 10);
    // JL_GC_PUSH* is required here to ensure that `x` is not deleted before
    // (aka, is gc-rooted until) the program reaches the corresponding JL_GC_POP()
    JL_GC_PUSH1(&x);

    double* xData = jl_array_data(x);

    size_t i;
    for (i = 0; i < jl_array_len(x); i++)
      xData[i] = i;

    jl_function_t *func  = jl_get_function(jl_base_module, "reverse!");
    jl_call(func, (jl_value_t**) &x, 1);
    printf("x = [");
    for (i = 0; i < jl_array_len(x); i++)
      printf("%e ", xData[i]);
    printf("]\n");
    JL_GC_POP();
  }
  {
    // 2D arrays
    printf("\n2D Array\n");
    int xData[5][6];
    for(int i = 0; i < 5; ++i) {
      for(int j = 0; j < 6; ++j) {
        xData[i][j] = i + 5*j;
      }
    }
    printf("x = [");
    for(int i = 0; i < 5; ++i) {
      printf("[ ");
      for(int j = 0; j < 6; ++j) {
        printf("%i ", xData[i][j]);
      }
      printf("]");
    }
    printf("]\n");


    jl_value_t* array_type = jl_apply_array_type((jl_value_t*)jl_float64_type, 2);
    jl_value_t* int_type   = jl_apply_array_type((jl_value_t*)jl_int32_type, 1);

    jl_value_t* dims       = jl_eval_string("(5, 6)");

    jl_array_t* x          = jl_ptr_to_array(array_type, xData, dims, 0);

    size_t i = jl_array_len((jl_value_t*)x);
    printf("size_t %li = jl_array_len(x) \n", i);

    int rank = jl_array_rank((jl_value_t*)x);
    printf("rank %i = jl_array_rank(x) \n", rank);

    printf("jl_array_dim(x, 0) = %li \n", jl_array_dim(x, 0));
    printf("jl_array_dim(x, 1) = %li \n", jl_array_dim(x, 1));

    jl_function_t *func  = jl_get_function(jl_base_module, "transpose");

    jl_value_t* res = jl_call(func, (jl_value_t**) &x, 1);
    int* resData = jl_array_data(x);

    printf("jl_array_dim(x, 0) = %li \n", jl_array_dim(x, 0));
    printf("jl_array_dim(x, 1) = %li \n", jl_array_dim(x, 1));

    printf("x = [");
    for(int i = 0; i < 5; ++i) {
      printf("[ ");
      for(int j = 0; j < 6; ++j) {
        printf("%i ", resData[6*i + j]);
      }
      printf("]");
    }
    printf("]\n");

  }

  /* strongly recommended: notify Julia that the
     program is about to terminate. this allows
     Julia time to cleanup pending write requests
     and run all finalizers
     */
  jl_atexit_hook(0);
  return 0;
}
