import mpdclient, os, strutils

const mpdLibrary {.strdefine.} = gorge "xdg-user-dir MUSIC"

var image = ""

let song = newMPDClient().currentSong

if song.isSome:

  let folder = mpdLibrary / parentDir song.get.file

  for file in folder.walkDirRec:
    let
      (_, realName, realExt) = file.splitFile
      name = realName.toLowerAscii
      ext = realExt.toLowerAscii
    if ext == ".png" or ext == ".jpg" or ext == ".jpeg":
      if image.len == 0: image = file
      elif name == "cover" or name == "folder" or name == "front":
        image = file
        break

echo image
