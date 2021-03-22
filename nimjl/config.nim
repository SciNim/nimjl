import os

# juliaPath should be parent folder of julia-bindir
# Use julia -E Sys.BINDIR to get the path
# Is it possible to resolve this at compile-time ?
const juliaPath* = getEnv("JULIA_PATH")
const juliaIncludesPath* = juliaPath / "include" / "julia"
const juliaHeader* = "julia.h"
const juliaLibPath* = juliaPath / "lib"
const juliaDepPath* = juliaPath / "lib" / "julia"

const libPrefix = "lib"
const libSuffix = ".so"
const juliaLibName* = juliaLibPath / libPrefix & "julia" & libSuffix

# TODO: handle more platform
{.passC: " -DJULIA_ENABLE_THREADING=1".}
{.passC: "-I" & juliaIncludesPath.}
{.passL: "-L" & juliaLibPath.}
{.passL: "-Wl,-rpath," & juliaLibPath.}
{.passL: "-L" & juliaDepPath.}
{.passL: "-Wl,-rpath," & juliaDepPath.}
{.passL: "-ljulia".}
# {.link: juliaLibName}

static:
  echo "juliaPath> ", juliaPath
  echo "juliaIncludesPath> ", juliaIncludesPath
  echo "juliaLibPath> ", juliaLibPath
  echo "juliaLibName> ", juliaLibName

