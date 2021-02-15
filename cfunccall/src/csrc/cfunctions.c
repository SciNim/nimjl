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
