import nimjl
import std/[os, strformat, exitprocs]

proc compileCurrentFile(curRun: static int) =
  let cmd = getCurrentCompilerExe() & &" cpp -d:run{curRun} -o:./run{curRun}.out " & currentSourcePath()
  debugEcho cmd
  discard execShellCmd(cmd)

proc cleanUp() =
  var envdir = "./julia-custom-env"
  if dirExists(envdir): removeDir(envdir)

  envdir = "./julia-empty-env"
  if dirExists(envdir): removeDir(envdir)

  discard tryRemoveFile("run1.out")
  discard tryRemoveFile("run2.out")
  discard tryRemoveFile("run3.out")


proc postJlInit() =
  echo "code executed after Julia VM is initialized and env is activated but before dependencies"
  let Pkg = Julia.getModule("Pkg")

  discard Pkg.update()
  discard Pkg.status()

proc firstRunmain() =
  ## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
  Julia.init(4):
    activate("./julia-custom-env")
    # Call postJlInit() if it exists
    # Call Pkg + external dependencies
    Pkg:
      add(name="LinearAlgebra")
      add("DSP")
  defer: Julia.exit()

proc mainNoPkgSameEnv() =
  ## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
  Julia.init(4):
    # activate julia venv
    activate("./julia-custom-env")
  defer: Julia.exit()

proc mainNoPkgDifferentEnv() =
  ## See https://pkgdocs.julialang.org/dev/api/#Pkg.add for more info
  Julia.init(4):
    activate("./julia-empty-env")
  defer: Julia.exit()

when isMainModule:
  when defined(run1):
    echo "First Run:"
    echo "  * Pkg.status show empty deps"
    echo "  * dependencies are downloaded"
    echo "==================================================="
    firstRunMain()
    echo "==================================================="
  elif defined(run2):
    echo "No Pkg in init but same env:"
    echo "  * Pkg.status show deps in projects"
    echo "==================================================="
    mainNoPkgSameEnv()
    echo "==================================================="
  elif defined(run3):
    echo "No Pkg in init and different env:"
    echo "  * Pkg.status show empty deps"
    echo "==================================================="
    mainNoPkgDifferentEnv()
    echo "==================================================="
  else:
    compileCurrentFile(curRun=1)
    compileCurrentFile(curRun=2)
    compileCurrentFile(curRun=3)
    discard execShellCmd("./run1.out")
    discard execShellCmd("./run2.out")
    discard execShellCmd("./run3.out")
    cleanUp()

