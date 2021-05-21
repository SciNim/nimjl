import ./config
import ./private/jlcores

type
  JlValue* = ptr jl_value
  JlModule* = ptr jl_module
  JlFunc* = ptr jl_func
  JlArray*[T] = ptr jl_array
  JlSym* = ptr jl_sym

type
  JlError* = object of IOError

{.push header: JuliaHeader.}
var
  JlMain*{.importc: "jl_main_module".}: JlModule
  JlCore*{.importc: "jl_core_module".}: JlModule
  JlBase*{.importc: "jl_base_module".}: JlModule
  JlTop*{.importc: "jl_top_module".}: JlModule

# Currently, you need to define setControlCHook AFTER jlVmInit() or it won't take effect
# var jl_interrupt_exception{.importc: "jl_interrupt_exception".}: JlValue
{.pop.}


