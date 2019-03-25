import os, strutils

const depth {.intdefine.} = 5

var dir = getCurrentDir()

for _ in 1..depth:
  for k, f in walkDir dir:
    if k != pcDir and f.endsWith ".nimble":
      quit 0
  if dir == "/":
    quit 1
  else:
    dir = parentDir dir

quit 1
