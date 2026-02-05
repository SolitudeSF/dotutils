import system/ansi_c, std/tables
import xcb/[xcb, xkb, aux]

proc `==`(a, b: XcbWindow): bool {.borrow.}
proc `==`(a, b: XcbAtom): bool {.borrow.}

const netActiveWindowAtomName = "_NET_ACTIVE_WINDOW"

var
  exiting = false
  screen: cint

proc exit {.noconv.} = exiting = true

setControlCHook exit

let
  conn = xcbConnect(nil, addr screen)
  netActiveWindowAtom = conn.reply(conn.internAtom(false, netActiveWindowAtomName.len, netActiveWindowAtomName), nil).atom
  rootScreen = conn.auxGetScreen screen
  root = rootScreen.root
  xkbExt = conn.reply(conn.xkbUseExtension(xcbXkbMajorVersion, xcbXkbMinorVersion), nil)[]
  xkbExtData = conn.getExtensionData(addr xcbXkbId)
  xkbBase = xkbExtData.firstEvent
  attributes = conn.reply(conn.getAttributes(root), nil)
  attributeValue = xcbEventMaskStructureNotify.uint32 or xcbEventMaskSubstructureNotify.uint32 or
    xcbEventMaskPropertyChange.uint32 or xcbEventMaskKeymapState.uint32 or attributes.yourEventMask

conn.changeAttributes root, xcbCwEventMask.uint32, addr attributeValue
conn.selectEvents xcbXkbIdUseCoreKbd.XcbXkbDeviceSpec, xcbXkbEventTypeStateNotify.uint16, 0, xcbXkbEventTypeStateNotify.uint16, 0xff, 0xff, nil
discard conn.flush

var
  windows = newTable[XcbWindow, uint8](128)
  lockedGroup: uint8
  activeWindow: XcbWindow
  event = conn.waitForEvent

while not exiting:
  let eventType = event.responseType and not 0x80'u8
  case eventType
  of xcbPropertyNotify:
    let event = cast[ptr XcbPropertyNotifyEvent](event)
    if event.window == root and event.atom == netActiveWindowAtom:
      let activeWindowReply = conn.reply(conn.getProperty(0, root, netActiveWindowAtom, xcbAtomWindow.XcbAtom, 0, 1), nil)
      activeWindow = cast[ptr XcbWindow](activeWindowReply.value)[]
      if activeWindow in windows:
        if lockedGroup != windows[activeWindow]:
          lockedGroup = windows[activeWindow]
          conn.latchLockState xcbXkbIdUseCoreKbd.XcbXkbDeviceSpec, 0, 0, 1, lockedGroup, 0, 0, 0
          discard conn.flush
      else:
        windows[activeWindow] = lockedGroup
      activeWindowReply.c_free
  of xcbDestroyNotify:
    windows.del cast[ptr XcbDestroyNotifyEvent](event).window
  else:
    if eventType == xkbBase:
      lockedGroup = cast[ptr XcbXkbStateNotifyEvent](event).lockedGroup
      windows[activeWindow] = lockedGroup
  event.c_free
  event = conn.waitForEvent

conn.disconnect
