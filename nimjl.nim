import ./nimjl/arrays
export arrays

import ./nimjl/cores
export cores

import ./nimjl/types
export types

import ./nimjl/errors
export errors

import ./nimjl/gc
export gc

import ./nimjl/functions
export functions

import ./nimjl/glucose
export glucose

import ./nimjl/conversions
export conversions

import ./nimjl/sysimage
export sysimage

import ./nimjl/extended_api
export extended_api

import ./nimjl/config

static:
  debugEcho "Nimjl> Using : ", JuliaPath, "/bin/julia v", JuliaMajorVersion, ".", JuliaMinorVersion, ".", JuliaPatchVersion

import std/exitprocs
proc jlVmProcessExit() =
  jlVmExit(0.cint)

addExitProc jlVmProcessExit

runnableExamples:
  import nimjl

  Julia.init() # Initialize Julia VM. Subsequent call to init will be ignored
  var myval = 4.0'f64
  discard Julia.println("Hello world") # No need for \n with Julia println function
  var res = Julia.sqrt(myval).to(float64) # Call Julia function "sqrt" and convert the result to a float
  echo res # sqrt(4.0) == 2.0
