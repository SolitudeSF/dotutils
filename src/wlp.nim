import std/[os, osproc, strutils]

proc setWallpapers(files: openArray[string]): int =
  var args: seq[string]
  for _, path in files:
    args.add "-cover"
    args.add path

  let process = startProcess(findExe "hsetroot", args = args, options = {poParentStreams})

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

      if n > files.high: files.setLen n + 1

      files[n] = if path.isAbsolute: path else: getCurrentDir() / path

    let file = open(wallPath, fmWrite)

    let code = setWallpapers files

    if code != 0:
      quit code

    for path in files:
      file.writeLine path

wlp()
