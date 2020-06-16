const LibraryName = "libjulia.so"

proc JULIA_DEFINE_FAST_TLS() {.cdecl, importc: "JULIA_DEFINE_FAST_TLS", header: "julia.h"}
proc jl_init*() {.cdecl, importc: "jl_init__threading", dynlib: LibraryName.}
proc jl_eval_string*(code: cstring) {.cdecl, importc: "jl_eval_string", dynlib: LibraryName.}
proc jl_atexit_hook*(exit_code : cint) {.cdecl, importc: "jl_atexit_hook", dynlib: LibraryName.}

echo "TLS"
JULIA_DEFINE_FAST_TLS() # only define this once, in an executable (not in a shared library) if you want fast code.
echo "init"
jl_init()
jl_eval_string("print(sqrt(2.0))")
jl_atexit_hook(0)

