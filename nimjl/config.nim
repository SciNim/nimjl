import os

{.used.}
# Const julia path
const csrc_nimjl* = "csrc/nimjl.c"
const juliaPath* = getEnv("JULIA_PATH")
const juliaIncludesPath* = juliaPath / "include" / "julia"
const juliaLibPath* = juliaPath / "lib"
const juliaDepPath* = juliaPath / "lib" / "julia"
const juliaHeader* = "julia.h"

{.passC: "-fPIC".}
{.passC: " -DJULIA_ENABLE_THREADING=1".}
{.passC: "-I" & juliaIncludesPath.}
{.passL: "-L" & juliaLibPath.}
{.passL: "-Wl,-rpath," & juliaLibPath.}
{.passL: "-L" & juliaDepPath.}
{.passL: "-Wl,-rpath," & juliaDepPath.}
{.passL: "-ljulia".}

{.compile: csrc_nimjl.}

# {.push cdecl}
# {.push header: juliaHeader.}

static:
  echo "juliaPath> ", juliaPath
  echo "juliaIncludesPath> ", juliaIncludesPath
  echo "juliaLibPath> ", juliaLibPath

