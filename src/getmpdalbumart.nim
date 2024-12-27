import std/[os, strutils]
import pkg/mpdclient

const mpdLibrary {.strdefine.} = gorge "xdg-user-dir MUSIC"

proc getImage(libraryPath: string): string =
  let song = newMPDClient().currentSong

  if song.isSome:

    let folder = libraryPath / parentDir song.get.file

    for file in folder.walkDirRec(yieldFilter = {pcFile, pcLinkToFile}):
      let
        (_, realName, realExt) = file.splitFile
        name = realName.toLowerAscii
        ext = realExt.toLowerAscii
      if ext == ".png" or ext == ".jpg" or ext == ".jpeg" or ext == ".jxl":
        if result.len == 0: result = file
        elif name == "cover" or name == "folder" or name == "front":
          result = file
          break

echo getImage mpdLibrary
