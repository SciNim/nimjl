# Nimjl
# Licensed and distributed under MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).

version       = "0.4.2"
author        = "Regis Caillaud"
description   = "Nim Julia bridge"
license       = "MIT"


# Dependencies
requires "nim >= 1.2.0"
requires "arraymancer"

import os
task finishSetup, "Setup JULIA_PATH":
  echo("""To finish Nimjl setup, add "export JULIA_PATH=JULIA_BINDIR/.." to your .bashrc or .profile. """)
  echo("JULIA_BINDIR=")
  exec("julia -E Sys.BINDIR")

after install:
  finishSetupTask()

after develop:
  finishSetupTask()
