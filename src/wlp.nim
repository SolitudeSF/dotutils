import os, osproc, strutils

proc setWallpapers(files: openArray[string]): int =
  var args: seq[string]
  for n, path in files:
    args.add "-z"
    args.add "--on"
    args.add $n
    args.add path

  let process = startProcess(findExe "setroot", args = args, options = {poParentStreams})

  result = waitForExit process

proc wlp =

  let wallPath = getConfigDir() / "wlp" / "files"

  var files: seq[string]

  for line in wallPath.lines:
    files.add line

  let argc = paramCount()

  if argc == 0:
    quit setWallpapers files
  else:
    doAssert argc mod 2 == 0, "Provide xinerama monitor number and image path pairs."

    let count = argc div 2

    for i in 1..count:
      let
        n = paramStr(i * 2 - 1).parseInt
        path = paramStr(i * 2)

      files[n] = if path.isAbsolute: path else: getCurrentDir() / path

    let file = open(wallPath, fmWrite)

    for path in files:
      file.writeLine path

    quit setWallpapers files

wlp()
