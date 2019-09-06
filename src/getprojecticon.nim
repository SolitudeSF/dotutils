import os, strutils

const
  depth {.intdefine.} = 5
  nimIcon = "👑"
  rustIcon = "🦀"
  pythonIcon = "🐍"
  goIcon = "🐹"

var dir = getCurrentDir()

template isFile(pc: PathComponent): bool = pc == pcFile or pc == pcLinkToFile
template finish(s: string) = stdout.write s; quit 0

for _ in 1..depth:
  for k, f in walkDir dir:
    if k.isFile:
      let n = f.extractFilename
      if n.endsWith ".nimble":
        finish nimIcon
      if n == "Cargo.toml":
        finish rustIcon
      if n == "setup.py" or n == "requirements.txt":
        finish pythonIcon
      if n == "go.mod" or n == "go.sum" or n == "Gopkg.yml" or n == "Gopkg.lock":
        finish goIcon
  if dir == "/":
    break
  else:
    dir = parentDir dir

stdout.write " "
quit 1
