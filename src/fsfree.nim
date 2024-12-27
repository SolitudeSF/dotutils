import std/[posix, strutils, math]

proc getFreeBytes(path: string): uint =
  var stat: Statvfs
  doAssert statvfs(path.cstring, stat) == 0
  result = stat.f_bavail * stat.f_frsize

func humanReadable(size: uint): string =
  let
    (denom, suffix) =
      if size > 1'u shl 40:
        (1 shl 40, "TB")
      elif size > 1'u shl 30:
        (1 shl 30, "GB")
      elif size > 1'u shl 20:
        (1 shl 20, "MB")
      elif size > 1'u shl 10:
        (1 shl 10, "KB")
      else:
        (1, "B")
    sizeScaled = size.int / denom
  if sizeScaled >= 100:
    result.addInt sizeScaled.round.int
  else:
    result.add sizeScaled.formatFloat(format = ffDecimal, precision = 1)
  result.add suffix

echo getFreeBytes(".").humanReadable
