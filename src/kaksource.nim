import os

let target = paramStr 1
var buffer: string

for file in target.walkDirRec(yieldFilter = {pcFile,pcLinkToFile},
                              followFilter = {pcDir,pcLinkToDir}):
  if file[^4..^1] == ".kak": stdout.writeLine file.readFile
