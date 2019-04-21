import os, random, strutils

var
  files: seq[string]
  dir = getCurrentDir()
  n = 1

for i in 1..paramCount():
  let arg = paramStr i
  if n == 0:
    n = arg.parseInt
  elif arg == "-n":
    n = 0
  else:
    dir = arg

for kind, path in dir.walkDir:
  if kind == pcFile:
    files.add path

if files.len > 0:
  randomize()

  if n == 1:
    echo sample files
  else:
    shuffle files
    for i in 0..<min(n, files.len):
      echo files[i]
else:
  quit 1
