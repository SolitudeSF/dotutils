# Package

version       = "0.1.6"
author        = "SolitudeSF"
description   = "Helper programs for my own workflow"
license       = "MIT"
srcDir        = "src"
bin           = @["getprojecticon", "getmpdalbumart", "randfile", "wlp", "chext"]


# Dependencies

requires "nim >= 1.0.0", "mpdclient >= 0.1.5"
