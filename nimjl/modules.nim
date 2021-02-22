import config
import basetypes
import strformat

## Check for nil result
proc nimjl_include_file*(file_name: string): ptr nimjl_value =
  result = nimjl_eval_string(&"include(\"{file_name}\")")

proc nimjl_using_module*(module_name: string): ptr nimjl_value =
  result = nimjl_eval_string(&"using {module_name}")

proc nimjl_get_module*(module_name: string): ptr nimjl_module =
  result = cast[ptr nimjl_module](nimjl_eval_string(module_name))


