import std/os

proc countFiles(dir: string): int =
  for _, _ in dir.walkDir:
    inc result

for paramNum in 1..paramCount():
  echo countFiles paramStr paramNum
