import std/[os, strutils]

proc chext =
  let
    name = paramStr(1)
    ext = paramStr(2)
    dot = name.rfind '.'

  if dot > 0:
    echo name[0..dot], ext
  else:
    echo name, '.', ext

chext()
