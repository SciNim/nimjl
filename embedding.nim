{.compile:"embedding.c", passc:"-DJULIA_ENABLE_THREADING=1", passc:"-I/home/rcaillaud/julia-1.4.2/include/julia", passL:"-lm" passL:"-Wl,-rpath,/home/rcaillaud/julia-1.4.2/lib/" passL:"-Wl,-rpath,/home/rcaillaud/julia-1.4.2/lib/julia" passL:"-ljulia".}

type nimjl_value {.importc: "jl_value_t*", header: "julia.h".} = distinct pointer
proc nimjl_init*() {.importc.}
proc nimjl_eval_string*(code: cstring) : nimjl_value {.importc.}
proc nimjl_atexit_hook*(exit_code : cint) {.importc.}
proc nimjl_unbox_float64*(value: nimjl_value) : float64 {.importc.}

echo "init"
nimjl_init()
echo "eval"
discard nimjl_eval_string("print(sqrt(2.0))")
echo ""
var test = nimjl_eval_string("sqrt(4.0)")
echo type(test)
echo test.repr
echo nimjl_unbox_float64(test)
echo "exithook"
## atexit cause stack overflow ?
#nimjl_atexit_hook(0)


##This approach didn't pan out. Too many pre processing to do in Julia header
## Wrapping from a C file is WAY easier

#const LibraryName = "libjulia.so"
#proc JULIA_DEFINE_FAST_TLS() {.cdecl, importc: "JULIA_DEFINE_FAST_TLS", header: "julia.h"}
#proc jl_init*() {.cdecl, importc: "jl_init__threading", dynlib: LibraryName.}
#proc jl_eval_string*(code: cstring) {.cdecl, importc: "jl_eval_string", dynlib: LibraryName.}
#proc jl_atexit_hook*(exit_code : cint) {.cdecl, importc: "jl_atexit_hook", dynlib: LibraryName.}
#
#echo "TLS"
##JULIA_DEFINE_FAST_TLS() # only define this once, in an executable (not in a shared library) if you want fast code.
#echo "init"
#jl_init()
#echo "eval"
#jl_eval_string("print(sqrt(2.0))")
#echo "exithook"
#jl_atexit_hook(0)
#
