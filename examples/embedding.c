#include "julia.h"
#include "stdio.h"

// JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.
jl_value_t *checked_eval_string(const char* code)
{
    jl_value_t *result = jl_eval_string(code);
    if (jl_exception_occurred()) {
        // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
        jl_call2(jl_get_function(jl_base_module, "showerror"),
                 jl_stderr_obj(),
                 jl_exception_occurred());
        jl_printf(jl_stderr_stream(), "\n");
        jl_atexit_hook(1);
        exit(1);
    }
    assert(result && "Missing return value but no exception occurred!");
    return result;
}

int ex1(int argc, char *argv[])
{
    /* required: setup the Julia context */
    jl_init();

    /* create a 1D array of length 100 */
    double length = 100;
    double *existingArray = (double*)malloc(sizeof(double)*length);

    /* create a *thin wrapper* around our C array */
    jl_value_t* array_type = jl_apply_array_type((jl_value_t*)jl_float64_type, 1);
    jl_array_t *x = jl_ptr_to_array_1d(array_type, existingArray, length, 0);

    /* fill in values */
    double *xData = (double*)jl_array_data(x);
    for (int i = 0; i < length; i++)
        xData[i] = i * i;

    /* import `Plots` into `Main` module with `using`*/
    jl_eval_string("using GR");
    jl_module_t* GR = (jl_module_t *)jl_eval_string("GR");;

    /* get `plot` function */
    jl_function_t *plot = jl_get_function(GR, "plot");

    /* create the plot */
    jl_value_t* p = jl_call1(plot, (jl_value_t*)x);


    /* display the plot */
    jl_function_t *disp = jl_get_function(jl_base_module, "display");
    jl_call1(disp, p);

    getchar();

    /* exit */
    jl_atexit_hook(0);
    return 0;
}

int simple_eval_string(int argc, char *argv[])
{
  jl_init();
  {
    printf("\neval_string \n");
    /* run Julia commands */
    jl_eval_string("print(sqrt(2.0))");
    printf("\n");
  }
  jl_atexit_hook(0);
  return 0;
}

int simple_call(int argc, char *argv[])
{
  jl_init();
  {
    printf("\njl_call1\n");
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    jl_value_t* argument = jl_box_float64(2.0);
    jl_value_t* ret = jl_call1(func, argument);
    double cret = jl_unbox_float64(ret);
    printf("cret=%f \n", cret);
  }
  {
    printf("\njl_call\n");
    jl_function_t *func = jl_get_function(jl_base_module, "sqrt");
    jl_value_t *argument = jl_box_float64(4.0);
    jl_value_t *ret = jl_call(func, (jl_value_t**)&argument, 1);
    double cret = jl_unbox_float64(ret);
    printf("cret=%f \n", cret);
  }
  jl_atexit_hook(0);
  return 0;
}

int arrays_stuff(int argc, char *argv[])
{
  jl_init();
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
    jl_value_t* ret = jl_call(func, (jl_value_t**) &x, 1);

    printf("x = [");
    for (i = 0; i < jl_array_len(x); i++)
      printf("%f ", xData[i]);
    printf("]\n");

    printf("size_t %li = jl_array_len(x)\n", jl_array_len((jl_value_t*)x));
    printf("rank %i = jl_array_rank(x) \n" , jl_array_rank((jl_value_t*)x));
    printf("jl_array_dim(x, 0) = %li \n"   , jl_array_dim(x, 0));
    printf("jl_array_dim(x, 1) = %li \n"   , jl_array_dim(x, 1));

    JL_GC_POP();

    double* retData = jl_array_data(ret);
    printf("retData = [");
    for (i = 0; i < jl_array_len(x); i++)
      printf("%f ", xData[i]);
    printf("]\n");
  }

  {
    // 2D arrays
    printf("\n2D Array\n");
    int xData[5][6];
    for(int i = 0; i < 5; ++i) {
      for(int j = 0; j < 6; ++j) {
        xData[i][j] = 6*i + j;
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
    jl_value_t* dims       = jl_eval_string("(5, 6)");
    jl_array_t* x          = jl_ptr_to_array(array_type, xData, dims, 0);

    printf("size_t %li = jl_array_len(x)\n", jl_array_len((jl_value_t*)x));
    printf("rank %i = jl_array_rank(x) \n" , jl_array_rank((jl_value_t*)x));
    printf("jl_array_dim(x, 0) = %li \n"   , jl_array_dim(x, 0));
    printf("jl_array_dim(x, 1) = %li \n"   , jl_array_dim(x, 1));

    jl_function_t *func  = jl_get_function(jl_base_module, "transpose");
    jl_value_t* res = jl_call(func, (jl_value_t**)&x, 1);
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

int external_module(int argc, char *argv[])
{
  /* required: setup the Julia context */
  jl_init();

  {
    // This works but can't pass args easily
    printf("include test.jl \n");
    // jl_eval_string("inlcude(\"test.jl\")");
    jl_eval_string("Base.include(Main, \"test.jl\")");
    jl_eval_string("using AAA");
    jl_function_t *func = jl_get_function(jl_main_module, "testMeBaby");
    // jl_function_t *func = jl_get_function(jl_main_module, "AAA.testMeBaby");

    if(func != NULL) {
      printf("func is not Null\n");
    }
    else {
      printf("func is null\n");
      jl_atexit_hook(0);
      return 0;
    }

    // create a 2D array of length 30 
    double length = 5*6;
    double *existingArray = (double*)malloc(sizeof(double)*length);

    jl_value_t* array_type = jl_apply_array_type((jl_value_t*)jl_float64_type, 2);
    jl_value_t* dims       = jl_eval_string("(5, 6)");
    jl_array_t* x          = jl_ptr_to_array(array_type, existingArray, dims, 0);

    /* fill in values */
    double *xData = (double*)jl_array_data(x);
    for (int i = 0; i < length; i++)
        xData[i] = i * i;

    jl_value_t* ret = jl_call1(func, (jl_value_t*)x);

    printf("len(ret)=%li \n", jl_array_len(ret));
    printf("rank %i = jl_array_rank(x) \n" , jl_array_rank((jl_value_t*)ret));

    int d1 = jl_array_dim(ret, 0);
    int d2 = jl_array_dim(ret, 1);

    JL_GC_PUSH1(&ret);
    int* xResult= jl_array_data(ret);
    printf("Result ?\n");

    printf("x = [");
    for (int i = 0; i < d1; i++)
      for (int j = 0; j < d2; j++)
        printf("%i ", xResult[i*d2+j]);
    printf("]\n");
    JL_GC_POP();

    free(existingArray);
    jl_atexit_hook(0);
    return 0;
  }
}

int main(int argc, char *argv[])
{
  // ex1(argc, argv);
  // simple_call(argc, argv);
  external_module(argc, argv);
}