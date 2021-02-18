
/* _GNU_SOURCE is only needed for for the non-Windows part of the
 * `find_julia_bindir` function.
 */
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#define _OS_WINDOWS_
#endif

#ifdef _OS_WINDOWS_
#include <windows.h>
#else
#include <dlfcn.h>
/* `libgen.h` is only needed for for the `find_julia_bindir` function. */
#include <libgen.h>
#endif

/* Load a minimal subset of the functions from julia.h dynamically.
/* We could get the definitions of these structs from
 * `#include "julia.h"`, but we only need to declare them and
 * including julia.h would interfere with masquerading the `jl_*`
 * functions as pointers.
 */
typedef struct _jl_value_t jl_value_t;
typedef struct _jl_sym_t jl_sym_t;
typedef struct _jl_module_t jl_module_t;

/* Declare pointers to the functions we need to load from libjulia.
 * Obviously these signatures must match the corresponding functions
 * in the julia.h that libjulia was built from.
 */
static const char* (*jl_ver_string)(void);
static void (*jl_init)(void);
static void (*jl_init_with_image)(const char*, const char*);
static int (*jl_is_initialized)(void);
static void (*jl_atexit_hook)(int);
static jl_value_t *(*jl_eval_string)(const char *);
static jl_sym_t *(*jl_symbol)(const char *);
static jl_module_t **p_jl_main_module;
#define jl_main_module (*p_jl_main_module)
static jl_value_t *(*jl_get_global)(jl_module_t *, jl_sym_t *);
static void *(*jl_unbox_voidpointer)(jl_value_t *);
static const char *(*jl_string_ptr)(jl_value_t *);
static jl_value_t *(*jl_exception_occurred)(void);

static int julia_functions_loaded = 0;

#ifdef _OS_WINDOWS_
#define dlsym_ GetProcAddress
#else
#define dlsym_ dlsym
#endif

/* Helper function to extract function pointers from the dynamically
 * loaded libjulia.
 */
#ifdef _OS_WINDOWS_
static void *load_function(HMODULE libjulia, const char *name, int *success)
#else
static void *load_function(void *libjulia, const char *name, int *success)
#endif
{
    void *p = dlsym_(libjulia, name);

    /* Unfortunately Julia renames `jl_init` to `jl_init__threading` if
     * Julia is compiled with threading support, so we have to check
     * which of these is available, or otherwise query Julia in some
     * other way (https://github.com/JuliaLang/julia/issues/28824).
     */
    if (!p && strcmp(name, "jl_init") == 0) {
        p = dlsym_(libjulia, "jl_init__threading");
    }

    /* Likewise for `jl_init_with_image`. */
    if (!p && strcmp(name, "jl_init_with_image") == 0) {
        p = dlsym_(libjulia, "jl_init_with_image__threading");
    }

    if (!p) {
        fprintf(stderr, "%s not found in libjulia.\n", name);
        *success = 0;
    }

    return p;
}

/* Open libjulia and extract pointers to the needed functions. */
static int load_julia_functions()
{
    if (julia_functions_loaded)
        return 1;

#ifdef _OS_WINDOWS_
    /* libjulia.dll needs to be in the same directory as the
     * executable or in PATH.
     */
    const char *library_name = "libjulia.dll";
    HMODULE libjulia = LoadLibrary(library_name);
#else
    /* libjulia.so needs to be in LD_LIBRARY_PATH. It could also be in
     * rpath (but that kind of defeats the purpose of dynamically
     * loading libjulia) or an absolute path could be given, computed
     * from other information.
     */
#ifdef __APPLE__
    const char *library_name = "libjulia.dylib";
#else
    const char *library_name = "libjulia.so";
#endif
    void *libjulia = dlopen(library_name, RTLD_LAZY | RTLD_GLOBAL);
#endif

    if (!libjulia) {
        fprintf(stderr, "Failed to load libjulia.\n");
        return 0;
    }

    int success = 1;
    jl_ver_string = load_function(libjulia, "jl_ver_string", &success);
    jl_init = load_function(libjulia, "jl_init", &success);
    jl_init_with_image = load_function(libjulia, "jl_init_with_image", &success);
    jl_is_initialized = load_function(libjulia, "jl_is_initialized", &success);
    jl_atexit_hook = load_function(libjulia, "jl_atexit_hook", &success);
    jl_eval_string = load_function(libjulia, "jl_eval_string", &success);
    jl_symbol = load_function(libjulia, "jl_symbol", &success);
    p_jl_main_module = load_function(libjulia, "jl_main_module", &success);
    jl_get_global = load_function(libjulia, "jl_get_global", &success);
    jl_unbox_voidpointer = load_function(libjulia, "jl_unbox_voidpointer", &success);
    jl_string_ptr = load_function(libjulia, "jl_string_ptr", &success);
    jl_exception_occurred = load_function(libjulia, "jl_exception_occurred", &success);

    if (success)
        julia_functions_loaded = 1;

    return success;
}

/* Helper function for loading of a custom system image. It is
 * unfortunate that this is needed since Julia should know much better
 * itself where things are located than we realistically can know. See
 * the comment where this function is called from `julia_initialize`
 * for further discussion.
 */
static char *find_julia_bindir()
{
    char *bindir = NULL;
#ifdef _OS_WINDOWS_
    HMODULE handle;
    if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           (LPCSTR)(uintptr_t)(jl_init), &handle)) {
        TCHAR *path = malloc(MAX_PATH * sizeof(*path));
        DWORD n = GetModuleFileNameA(handle, path, MAX_PATH);
        if (n > 0) {
            /* Poor man's dirname() on Windows. A better solution
             * might involve _splitpath_s.
             */
            while (--n > 0) {
                if (path[n - 1] == '/' || path[n - 1] == '\\') {
                    path[n] = (TCHAR)0;
                    break;
                }
            }
            bindir = (char *)path;
        }
    }
#else
    Dl_info dlinfo;
    if (dladdr((void *)jl_init, &dlinfo) != 0 && dlinfo.dli_fname) {
        char *file_path = strdup(dlinfo.dli_fname);
        (void)asprintf(&bindir, "%s/../%s", dirname(file_path), "bin");
        free(file_path);
    }
#endif
    return bindir;
}

/* Helper function to retrieve pointers to cfunctions on the Julia side. */
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

void nimjl_init(int code) {
  if(!load_julia_functions()) {
    printf("Error loading functions\n");
    return;
  }
  jl_init();
  return;
}

void nimjl_atexit_hook(int code) { jl_atexit_hook(code); }

jl_value_t *nimjl_eval_string(char *code)
{
  return jl_eval_string(code);
}

void * nimjl_unbox_voidpointer(jl_value_t * p)
{
  return jl_unbox_voidpointer(p);
}
