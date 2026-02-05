import system/ansi_c
import xcb/[xcb, xfixes]

proc `==`(a, b: XcbAtom): bool {.borrow.}
proc unreachable {.noreturn.} = doAssert false

proc getAtom(conn: ptr XcbConnection, name: string): XcbAtom =
  let
    cookie = conn.internAtom(false, name.len.uint16, name.cstring)
    reply = conn.reply(cookie, nil)
  if reply == nil:
    return xcbNone.XcbAtom
  result = reply.atom
  c_free reply

proc clipmon =
  let
    conn = xcbConnect(nil, nil)
    screen = conn.getSetup.rootsIterator.data[0]
    root = screen.root
    extXfixes = conn.getExtensionData(addr xcbXfixesId)
    atomClipboard = conn.getAtom "CLIPBOARD"
    atomUtf8 = conn.getAtom "UTF8_STRING"
    atomProp = conn.getAtom "XSEL_DATA"
    mask = xcbXfixesSelectionEventMaskSetSelectionOwner.uint32
    win = conn.generateId.XcbWindow

  c_free conn.reply(conn.xfixesQueryVersion(6, 0), nil)

  conn.createWindow(screen.rootDepth, win, root, 0, 0, 1, 1, 0,
    xcbWindowClassInputOutput.uint16, screen.rootVisual, 0, nil)
  conn.selectSelectionInput(root, atomClipboard, mask)
  doAssert conn.flush > 0

  var output = ""

  while true:
    let
      event = conn.waitForEvent
      responseType = event.responseType and 0x7f

    case responseType
    of xcbSelectionNotify:
      let event = cast[ptr XcbSelectionNotifyEvent](event)
      if event.property == atomProp:
        let
          cookie = conn.getProperty(0, win, atomProp, xcbGetPropertyTypeAny.XcbAtom, 0, 1000000)
          reply = conn.reply(cookie, nil)

        if reply != nil:
          let len = reply.valueLength
          output.setLen len
          copyMem output[0].addr, reply.value, len
          echo output
          c_free reply

        conn.deleteProperty win, atomProp
    else:
      case responseType - extXfixes.firstEvent
      of xcbXfixesSelectionNotify:
        let event = cast[ptr XcbXfixesSelectionNotifyEvent](event)
        if event.selection == atomClipboard:
          conn.convertSelection(win, atomClipboard, atomUtf8, atomProp, xcbCurrentTime.XcbTimestamp)
          doAssert conn.flush > 0
      else:
        unreachable()

    c_free event

clipmon()
