import std/[os, strutils, strformat]

when defined(windows):
  {.error: "Compilation on Windows is not supported yet.".}

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

# Platform-specific library naming
const libPrefix = "lib"
when defined(macosx) or defined(macos):
  const libSuffix = ".dylib"
elif defined(windows):
  const libSuffix = ".dll"
else:  # Linux, BSD, etc.
  const libSuffix = ".so"

const JuliaLibName* = JuliaLibPath / libPrefix & "julia" & libSuffix

# Version detection
when defined(nimjl_cross_compile):
  # Cross-compilation mode: Extract version from library filename
  # This is less robust but necessary when Julia binary is not available for the host platform
  # Expects library naming: libjulia.MAJOR.MINOR.PATCH.{so|dylib}
  static:
    echo "Nimjl> Cross-compilation mode enabled"

  const versionPattern = &"{JuliaLibPath}/{libPrefix}julia.*{libSuffix}"
  # Use shell to find versioned library file
  const findLibCmd = when defined(macosx) or defined(macos):
    &"ls {JuliaLibPath}/{libPrefix}julia.*.*.*.dylib 2>/dev/null | head -1"
  else:
    &"ls {JuliaLibPath}/{libPrefix}julia.so.*.*.* 2>/dev/null | head -1"

  const (libFileOutput, libExitCode) = gorgeEx(findLibCmd)
  when libExitCode != 0:
    {.error: "Nimjl> Fatal error! Could not find versioned Julia library for cross-compilation.".}

  # Extract version from filename
  # For macOS: libjulia.1.11.7.dylib -> 1.11.7
  # For Linux: libjulia.so.1.11.7 -> 1.11.7
  const libFileName = libFileOutput.strip().splitPath().tail
  const versionStr = when defined(macosx) or defined(macos):
    # Remove "libjulia." prefix and ".dylib" suffix
    libFileName.replace(libPrefix & "julia.", "").replace(libSuffix, "")
  else:
    # Remove "libjulia.so." prefix
    libFileName.replace(libPrefix & "julia" & libSuffix & ".", "")

  const JuliaArrayVersion* = versionStr.split(".")
  const JuliaMajorVersion* = JuliaArrayVersion[0].parseInt()
  const JuliaMinorVersion* = JuliaArrayVersion[1].parseInt()
  const JuliaPatchVersion* = if JuliaArrayVersion.len > 2: JuliaArrayVersion[2].parseInt() else: 0

else:
  # Normal mode: Query Julia binary for version
  const JlVersionCmd = JuliaPath / "bin" / "julia" & " -E VERSION"
  const (cmdOutput, exitCode) = gorgeEx(JlVersionCmd)
  when exitCode != 0:
    {.error: "Nimjl> Fatal error! Julia could not be found on your system.".}

  const JuliaArrayVersion* = cmdOutput.split("\"")[1].split(".")
  # For release: result has the form ["v", "1.6.0", ""] -> splitting [1] yields ["1", "6", "0"]
  # For dev: result has the form ["v", "1.7.0-DEV", "667"] -> splitting [1] yields ["1", "7", "0-DEV", "667"]
  const JuliaMajorVersion* = JuliaArrayVersion[0].parseInt()
  const JuliaMinorVersion* = JuliaArrayVersion[1].parseInt()
  const JuliaPatchVersion* = JuliaArrayVersion[2].parseInt()

static:
  echo "Nimjl> ", JuliaPath
  echo "Nimjl> Using : ", JuliaPath, "/bin/julia v", JuliaMajorVersion, ".", JuliaMinorVersion, ".", JuliaPatchVersion

# Compiler and linker flags
{.passC: "-DJulia_ENABLE_THREADING=1".}
{.passC: "-I" & JuliaIncludesPath.}
{.passL: "-L" & JuliaLibPath.}

# Platform-specific rpath handling
when defined(macosx) or defined(macos):
  {.passL: "-Wl,-rpath," & JuliaLibPath.}
  {.passL: "-Wl,-rpath," & JuliaDepPath.}
elif not defined(windows):
  {.passL: "-Wl,-rpath," & JuliaLibPath.}
  {.passL: "-Wl,-rpath," & JuliaDepPath.}

{.passL: "-L" & JuliaDepPath.}
{.passL: "-ljulia".}

# Workaround for Julia 1.6.0
# See https://github.com/JuliaLang/julia/issues/40524
when (JuliaMajorVersion, JuliaMinorVersion) == (1, 6):
  const internalJuliaLibName* = JuliaDepPath / libPrefix & "julia-internal" & libSuffix
  {.passL: "-ljulia-internal".}
