import zippy/[tarballs, ziparchives]
import
  std/[asyncdispatch, httpclient,
     strformat, strutils, os]

proc getProjectDir*(): string {.compileTime.} =
  currentSourcePath.rsplit(DirSep, 1)[0]

proc onProgressChanged*(total, progress, speed: BiggestInt) {.async.} =
  echo &"Downloaded {progress} of {total}"
  echo &"Current rate: {speed.float64 / (1000*1000):4.3f} MiBi/s" # TODO the unit is neither MB or Mb or MiBi ???

proc downloadTo*(url, targetDir, filename: string) {.async.} =
  var client = newAsyncHttpClient()
  defer: client.close()
  client.onProgressChanged = onProgressChanged
  echo "Starting download of \"", url, '\"'
  echo "Storing temporary into: \"", targetDir, '\"'
  await client.downloadFile(url, targetDir / filename)

proc downloadUrl*(url, targetDir, filename: string) =
  waitFor url.downloadTo(targetDir, filename)

proc uncompress*(targetDir, filename: string, delete = true) =
  let tmp = targetDir / "tmp"
  if dirExists(tmp):
    removeDir(tmp)
  let (_, _, fileExt) = filename.splitFile()
  if  fileExt == ".zip":
    ziparchives.extractAll(targetDir / filename, tmp)
  elif fileExt == ".gz" or fileExt == ".tar":
    tarballs.extractAll(targetDir / filename, tmp)
  else:
    echo "Error : Unknown archive format. Should .zip or .tar.gz"
  copyDirWithPermissions(tmp, targetDir)
  if delete:
    removeDir(tmp)
    removeFile(targetDir / filename)

