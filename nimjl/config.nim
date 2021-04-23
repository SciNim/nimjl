import os
import strutils

# JuliaPath should be parent folder of Julia-bindir
# Use Julia -E Sys.BINDIR to get the path
# Is it possible to resolve this at compile-time ?

const JuliaBinPath = gorge("julia -E Sys.BINDIR").replace("\"", "")
const JuliaPath* = if not existsEnv("JULIA_PATH"): JuliaBinPath.parentDir() else: getEnv("JULIA_PATH")
const JuliaIncludesPath* = JuliaPath / "include" / "julia"
const JuliaHeader* = "julia.h"
const JuliaLibPath* = JuliaPath / "lib"
const JuliaDepPath* = JuliaPath / "lib" / "julia"

const JlVersionCmd = JuliaPath / "bin" / "julia" & " -E VERSION"
const JuliaVersion = gorge(JlVersionCmd).split("\"")[1].split(".")
  # For release : result has the form ["v", "1.6.0", ""] -> splitting [1] yiels ["1", "6, "0"]
  # For dev: result has the form ["v", "1.7.0-DEV", "667"] -> splitting [1] yiels ["1", "7, "0-DEV", "667"]
const JuliaMajorVersion* = JuliaVersion[0].parseInt
const JuliaMinorVersion* = JuliaVersion[1].parseInt
const JuliaPatchVersion* = if not JuliaVersion[2].contains("DEV"): JuliaVersion[2].parseInt else: JuliaVersion[3].parseInt
const libPrefix = "lib"
const libSuffix = ".so"
const JuliaLibName* = JuliaLibPath / libPrefix & "julia" & libSuffix

# TODO: handle more platform
{.passC: " -DJulia_ENABLE_THREADING=1".}
{.passC: "-I" & JuliaIncludesPath.}
{.passL: "-L" & JuliaLibPath.}
{.passL: "-Wl,-rpath," & JuliaLibPath.}
{.passL: "-L" & JuliaDepPath.}
{.passL: "-Wl,-rpath," & JuliaDepPath.}
{.passL: "-ljulia".}

# Workaround for Julia 1.6.0
when (JuliaMajorVersion, JuliaMinorVersion, JuliaPatchVersion) == (1, 6, 0):
  const internalJuliaLibName* = JuliaDepPath / libPrefix & "Julia-internal" & libSuffix
  {.passL: "-ljulia-internal".}

# static:
#   echo "JuliaPath> ", JuliaPath
#   echo "JuliaIncludesPath> ", JuliaIncludesPath
#   echo "JuliaLibPath> ", JuliaLibPath
#   echo "JuliaLibName> ", JuliaLibName
