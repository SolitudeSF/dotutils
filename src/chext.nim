import terminal, os, strutils

proc chext =
  let
    istty = stdin.isatty
    name = if istty:
      paramStr(1)
    else:
      stdin.readAll
    ext = paramStr(if istty: 2 else: 1)
    dot = name.rfind '.'

  if dot > 0:
    echo name[0..dot] & ext
  else:
    echo name & "." & ext

chext()
