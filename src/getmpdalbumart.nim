import libmpdclient, os, strutils

const mpdLibrary {.strdefine.} = gorge "xdg-user-dir MUSIC"

var
  image = ""
  mpd = mpdConnectionNew(nil, 0, 30000)

discard mpd.mpdSendCurrentSong

let song = mpd.mpdRecvSong

if song != nil:
  let
    uri = song.mpdSongGetUri
    folder = mpdLibrary / parentDir $uri

  for file in folder.walkDirRec:
    let
      (_, realName, realExt) = file.splitFile
      name = realName.toLowerAscii
      ext = realExt.toLowerAscii
    if ext == ".png" or ext == ".jpg" or ext == ".jpeg":
      if image == "": image = file
      elif name == "cover" or name == "folder":
        image = file

echo image
mpd.mpdConnectionFree
