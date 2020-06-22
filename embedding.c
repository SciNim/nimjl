#include <julia.h>
#include <stdio.h>

JULIA_DEFINE_FAST_TLS() // only define this once, in an executable (not in a shared library) if you want fast code.

  void nimjl_init() {
    jl_init();
  }

jl_value_t* nimjl_eval_string(char* code) {
  jl_eval_string(code);
}

void nimjl_atexit_hook(int code) {
  nimjl_atexit_hook(code);
}

double nimjl_unbox_float64(jl_value_t* value) {
  if(jl_typeis(value, jl_float64_type))
  {
    return jl_unbox_float64(value);
  }
  else
  {
    printf("ERROR: expected type float 64 code: %i but got %i instead.\n", jl_float64_type, jl_typeof(value));
  }
}

//int main(int argc, char *argv[])
//{
//    /* required: setup the Julia context */
//    jl_init();
//
//    {
//      /* run Julia commands */
//      jl_eval_string("print(sqrt(2.0))");
//    }
//    {
//      // 1D arrays
//
//      jl_value_t* array_type = jl_apply_array_type((jl_value_t*)jl_float64_type, 1);
//      jl_array_t* x          = jl_alloc_array_1d(array_type, 10);
//      // JL_GC_PUSH* is required here to ensure that `x` is not deleted before
//      // (aka, is gc-rooted until) the program reaches the corresponding JL_GC_POP()
//      JL_GC_PUSH1(&x);
//
//      double* xData = jl_array_data(x);
//
//      size_t i;
//      for (i = 0; i < jl_array_len(x); i++)
//          xData[i] = i;
//
//      jl_function_t *func  = jl_get_function(jl_base_module, "reverse!");
//      jl_call(func, (jl_value_t**) &x, 1);
//      printf("\n");
//      printf("x = [");
//      for (i = 0; i < jl_array_len(x); i++)
//          printf("%e ", xData[i]);
//      printf("]\n");
//      JL_GC_POP();
//    }
//
//    /* strongly recommended: notify Julia that the
//         program is about to terminate. this allows
//         Julia time to cleanup pending write requests
//         and run all finalizers
//    */
//    jl_atexit_hook(0);
//    return 0;
//}
