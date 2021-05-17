# Nimjl
# Licensed and distributed under MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).

version       = "0.4.5"
author        = "Regis Caillaud"
description   = "Nim Julia bridge"
license       = "MIT"
installDirs   = @["install"]


# Dependencies
requires "nim >= 1.2.0"
requires "arraymancer"

task installjulia, "Install Julia":
  selfExec("r install/juliainstall.nim")
