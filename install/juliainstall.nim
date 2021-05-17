import installer
import std/[os, osproc]
import std/strformat

let juliaVersion = "1.6.1"
let libjuliaUrl = &"https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-{juliaVersion}-linux-x86_64.tar.gz"
let juliaFolder = &"julia-{juliaVersion}"

proc uncompressJulia(url, target: string, delete: bool = true) =
  let filename = libjuliaUrl.extractFilename()
  if not fileExists(filename):
    downloadUrl(url, target, filename)
  # uncompress can't be used because of symLinks
  # uncompress(target, filename, false)
  when defined(linux):
    let cmdStr = &"tar -xzf {target / filename} -C {target}"
    discard execCmd(cmdStr)
    setFilePermissions(target / juliaFolder / "bin" / "julia", {fpUserExec, fpUserWrite, fpUserRead, fpGroupRead, fpOthersRead})
    if delete:
      removeFile(target / filename)

proc downloadJulia*()=
  if not dirExists("third_party"):
    createDir("third_party")
  let target = getProjectDir().parentDir() / "third_party"
  if not dirExists(target / juliaFolder):
    uncompressJulia(libjuliaUrl, target)

when isMainModule:
  downloadJulia()
