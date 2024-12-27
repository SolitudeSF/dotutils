import std/[os, strutils, options, terminal]

type
  Language = enum
    Nim, Rust, Python, Go

const
  icons = [Nim: " ", " ", " ", " "]
  iconColors = [Nim: fgYellow, fgRed, fgBlue, fgCyan]
  emojis = [Nim: "👑", "🦀", "🐍", "🐹"]

proc getLanguage(dir: string, depth = 5): Option[Language] =
  var dir = dir
  for _ in 1..depth:
    for k, f in walkDir dir:
      if k == pcFile or k == pcLinkToFile:
        let n = f.extractFilename
        if n.endsWith ".nimble":
          return some Nim
        elif n == "Cargo.toml":
          return some Rust
        elif n == "setup.py" or n == "requirements.txt":
          return some Python
        elif n == "go.mod" or n == "go.sum" or n == "Gopkg.yml" or n == "Gopkg.lock":
          return some Go
    if dir == "/":
      break
    else:
      dir = parentDir dir

let lang = getCurrentDir().getLanguage
if lang.isSome:
  stdout.write emojis[lang.unsafeGet]
else:
  stdout.write ' '
  quit 1
