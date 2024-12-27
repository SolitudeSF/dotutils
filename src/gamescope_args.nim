import xcb/[xcb, randr]
import std/strformat

proc screenOfDisplay(c: ptr XcbConnection, screen: cint): ptr XcbScreen =
  var screen = screen
  var iter = c.getSetup.rootsIterator
  while iter.rem > 0:
    if screen == 0:
      return iter.data[0].addr
    iter.addr.next
    dec screen

var screenNumber: cint
let
  conn = xcbConnect(nil, addr screenNumber)
  screen = conn.screenOfDisplay(screenNumber)
  screenInfo = conn.reply(conn.getScreenInfo screen.root, nil)

echo &"-w {screen.widthInPixels} -h {screen.heightInPixels} -r {screenInfo.rate}"
