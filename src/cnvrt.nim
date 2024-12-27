import std/[os, osproc, tempfiles, strformat, macros, genasts]
import pkg/cligen

type
  CommandError = object of CatchableError

  CHDType = enum
    cd, dvd

proc assertDeps(deps: varargs[string]) =
  var notFound = false
  for dep in deps:
    if dep.findExe.len == 0:
      stderr.writeLine &"{dep} is not found"
      notFound = true
  if notFound: quit 1

proc runCommand(exe: string, args: openArray[string]) =
  let
    process = startProcess(exe, args = args, options = {poUsePath, poParentStreams})
    code = process.waitForExit
  close process
  if code != 0:
    raise newException(CommandError, &"{exe} failed with {code}")

proc dependsOnImpl(commands: openArray[string], def: NimNode): NimNode =
  var prelude = newStmtList(newCall "assertDeps")
  for command in commands:
    prelude[0].add newLit command
    prelude.add:
      genAst(cmdIdent = ident command, command):
        template cmdIdent(args: varargs[string, `$`]) = runCommand(command, args)
  let body = def[6].copyNimTree
  result = def
  result[6] = prelude
  for child in body:
    result[6].add child

macro dependsOn(commands: static[openArray[string]], def: untyped): untyped = dependsOnImpl(commands, def)
macro dependsOn(command: static[string], def: untyped): untyped = dependsOnImpl([command], def)

proc zpaq(dirs: seq[string]) {.dependsOn: ["tar", "lrzip"].} =
  ## Compress folder into tar.zpaq
  for dir in dirs:
    let dir = dir.normalizePathEnd
    doAssert dir.dirExists
    let tarball = dir.changeFileExt "tar"
    tar "-cf", tarball, dir
    lrzip "-z", "-S", ".zpaq", tarball
    removeFile tarball

proc dwarfs(dirs: seq[string], level: 0..9 = 9) {.dependsOn: "mkdwarfs".} =
  ## Compress folder to dwarfs image
  let level = $level
  for dir in dirs:
    doAssert dir.dirExists
    mkdwarfs "-l", level, "-i", dir, "-o", dir.normalizePathEnd.changeFileExt "dwarfs"

proc chd(files: seq[string], `type` = cd) {.dependsOn: "chdman".} =
  ## Convert disk images to chd
  const commands = [
    cd: "createcd",
    dvd: "createdvd"
  ]
  for file in files:
    doAssert file.fileExists
    chdman commands[`type`], "-i", file, "-o", file.changeFileExt "chd"

proc jxl(files: seq[string], `no-icc` = false, effort: 1..9 = 9) {.dependsOn: ["vips", "exiftool"].} =
  ## Convert image to jxl
  let effort = $effort
  if `no-icc`:
    for file in files:
      doAssert file.fileExists
      let tmp = genTempPath("cnvrt-", file.splitFile.ext)
      exiftool "-icc_profile:all=", file, "-o", tmp
      vips "jxlsave", "-e", effort, tmp, file.changeFileExt "jxl"
      removeFile tmp
  else:
    for file in files:
      doAssert file.fileExists
      vips "jxlsave", "-e", effort, file, file.changeFileExt "jxl"

proc opus(files: seq[string], bitrate = 256) {.dependsOn: "opusenc".} =
  ## Convert audio file to opus
  let cmdPrefix = &"opusenc --quiet --bitrate {bitrate} "
  var cmds = newSeq[string](files.len)
  for n, file in files:
    cmds[n] = &"{cmdPrefix}{quoteShell file} {quoteShell file.changeFileExt \"opus\"}"
  let code = execProcesses(cmds, options = {poUsePath, poParentStreams})
  if code != 0:
    raise newException(CommandError, &"opusenc failed with {code}")

dispatchMulti(
  ["multi", doc = "Multitool converter\n\n"],
  [chd],
  [jxl],
  [dwarfs],
  [zpaq],
  [opus]
)
