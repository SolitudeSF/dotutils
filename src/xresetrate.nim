import std/os
import xcb/[xcb, randr]

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
  randrVersion = conn.reply(conn.randrQueryVersion(1, 1), nil)
  screen = conn.screenOfDisplay(screenNumber)
  screenInfo = conn.reply(conn.getScreenInfo screen.root, nil)

discard conn.reply(conn.setScreenConfig(screen.root, screenInfo.timestamp, screenInfo.configTimestamp, 0, screenInfo.rotation, 60), nil)
sleep 4
discard conn.reply(conn.setScreenConfig(screen.root, screenInfo.timestamp, screenInfo.configTimestamp, 0, screenInfo.rotation, screenInfo.rate), nil)
