# Package

version       = "0.1.4"
author        = "SolitudeSF"
description   = "Helper programs for my own workflow"
license       = "MIT"
srcDir        = "src"
bin           = @["getprojecticon", "getmpdalbumart", "randfile"]


# Dependencies

requires "nim >= 0.20.0", "mpdclient >= 0.1.1"
