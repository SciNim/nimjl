import std/os
import std/strutils

when defined(windows):
  {.error: "Compilation on windows is not supported.".}

proc JuliaBinPath*() : string {.compileTime.} =
  gorge("julia -E Sys.BINDIR").replace("\"", "")

# JuliaPath should be parent folder of Julia-bindir
# This is resolved AT COMPILE TIME. Therefore, using the environment of the machine that compile.
# If you want to ship a binary, you need to install in a fixed path and pass this path using -d:JuliaPath="/path/to/Julia"
const JuliaPath* {.strdefine.} = if not existsEnv("JULIA_PATH"): JuliaBinPath().parentDir().normalizedPath() else: getEnv("JULIA_PATH")

const JuliaIncludesPath* = JuliaPath / "include" / "julia"
const JuliaHeader* = "julia.h"
const JuliaLibPath* = JuliaPath / "lib"
const JuliaDepPath* = JuliaPath / "lib" / "julia"

const libPrefix = "lib"
when defined(osx):
  const libSuffix = ".dylib"
else:
  const libSuffix = ".so"

const JuliaLibName* = JuliaLibPath / libPrefix & "julia" & libSuffix

when defined(nimjl_cross_compile):
  # This will use bash to extract the version from the naming of the file
  # It's less robust and thus not preferred but necessary for cross-compilation
  const
    JuliaLibPattern = JuliaLibPath / libPrefix & "julia*" & libSuffix
    prefixLen = len(libPrefix)+len("julia")+1 # length of the string 'libjulia.'
    suffixLen = len(libSuffix)
    JlVersionCmd = fmt"cd {JuliaLibPath} && name=$(echo libjulia.*.*.*.dylib); vers=$\{name:{prefixLen}:-{suffixLen}\}; echo $vers"
else:
  const JlVersionCmd = JuliaPath / "bin" / "julia" & " -E VERSION"

const (cmdOutput, exitCode) = gorgeEx(JlVersionCmd)
static:
  echo "Nimjl> ", JuliaPath
when exitCode != 0:
  {.error: "Nimjl> Fatal error ! Julia could not be found on your system.".}

const JuliaArrayVersion* = cmdOutput.split("\"")[1].split(".")

  # For release : result has the form ["v", "1.6.0", ""] -> splitting [1] yields ["1", "6, "0"]
  # For dev: result has the form ["v", "1.7.0-DEV", "667"] -> splitting [1] yields ["1", "7, "0-DEV", "667"]
const JuliaMajorVersion* = JuliaArrayVersion[0].parseInt()
const JuliaMinorVersion* = JuliaArrayVersion[1].parseInt()
const JuliaPatchVersion* = JuliaArrayVersion[2].parseInt()

# TODO: handle more platform
{.passC: " -DJulia_ENABLE_THREADING=1".}
{.passC: "-I" & JuliaIncludesPath.}
{.passL: "-L" & JuliaLibPath.}
{.passL: "-Wl,-rpath," & JuliaLibPath.}
{.passL: "-L" & JuliaDepPath.}
{.passL: "-Wl,-rpath," & JuliaDepPath.}
{.passL: "-ljulia".}

# Workaround for Julia 1.6.0
# See https://github.com/JuliaLang/julia/issues/40524
when (JuliaMajorVersion, JuliaMinorVersion) == (1, 6):
  const internalJuliaLibName* = JuliaDepPath / libPrefix & "julia-internal" & libSuffix
  {.passL: "-ljulia-internal".}
