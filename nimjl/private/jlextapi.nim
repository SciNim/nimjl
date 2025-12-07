## Extended Julia C API bindings
##
## Additional low-level C bindings for Julia API functions

import ../config
import ./jlcores  # Import type definitions

{.push nodecl, header: JuliaHeader, dynlib: JuliaLibName.}

# Module operations
proc jl_module_name*(m: ptr jl_module): ptr jl_sym {.importc: "jl_module_name".}
proc jl_module_parent*(m: ptr jl_module): ptr jl_module {.importc: "jl_module_parent".}
proc jl_symbol_name*(sym: ptr jl_sym): cstring {.importc: "jl_symbol_name".}

# Type checking
proc jl_is_nothing*(val: ptr jl_value): cint {.importc: "jl_is_nothing".}
proc jl_is_tuple*(val: ptr jl_value): cint {.importc: "jl_is_tuple".}
proc jl_is_array*(val: ptr jl_value): cint {.importc: "jl_is_array".}
proc jl_is_string*(val: ptr jl_value): cint {.importc: "jl_is_string".}

# String operations
proc jl_string_len*(s: ptr jl_value): csize_t {.importc: "jl_string_len".}

# Tuple/struct operations
proc jl_nfields*(val: ptr jl_value): cint {.importc: "jl_nfields".}

# GC control
proc jl_gc_safepoint*() {.importc: "jl_gc_safepoint".}

# Threading
proc jl_n_threads*(): cint {.importc: "jl_n_threads".}
proc jl_threadid*(): cint {.importc: "jl_threadid".}

{.pop.}
