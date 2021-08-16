# Nimjl
# Licensed and distributed under MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
version       = "0.5.7"
author        = "Regis Caillaud"
description   = "Nim Julia bridge"
license       = "MIT"
# installDirs   = @["third_party", "install"]

# Dependencies
requires "nim >= 1.4.0"
requires "arraymancer >= 0.6.3"

# TODO finish auto installation of Julia
task installjulia, "Install Julia":
  selfExec("r install/juliainstall.nim")

task runexamples, "Run all examples":
  withDir "examples":
    for fstr in listFiles("."):
      echo fstr
      if fstr.endsWith(".nim"):
        echo "running ", fstr
        selfExec("cpp -r -d:release " & fstr)
