import std/os
import std/strutils

const JuliaBinPath = gorge("julia -E Sys.BINDIR").replace("\"", "")

# JuliaPath should be parent folder of Julia-bindir
# This is resolved AT COMPILE TIME. Therefore, using the environment of the machine that compile.
# If you want to ship a binary, you need to install in a fixed path and pass this path using -d:JuliaPath="/path/to/Julia"
const JuliaPath* {.strdefine.} = if not existsEnv("JULIA_PATH"): JuliaBinPath.parentDir() else: getEnv("JULIA_PATH")
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
const JuliaPatchVersion* = JuliaVersion[2].parseInt
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

# Workaround for Julia 1.6.0 and 1.6.1
# See https://github.com/JuliaLang/julia/issues/40524
when (JuliaMajorVersion, JuliaMinorVersion) == (1, 6) and (JuliaPatchVersion == 0 or JuliaPatchVersion == 1):
  const internalJuliaLibName* = JuliaDepPath / libPrefix & "Julia-internal" & libSuffix
  {.passL: "-ljulia-internal".}

