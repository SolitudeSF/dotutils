import os

for file in 1.paramStr.walkDirRec(yieldFilter = {pcFile, pcLinkToFile},
                                  followFilter = {pcDir, pcLinkToDir}):
  if file[^4..^1] == ".kak": echo file.readFile
