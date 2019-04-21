# Package

version       = "0.1.1"
author        = "SolitudeSF"
description   = "Helper programs for my own workflow"
license       = "MIT"
srcDir        = "src"
bin           = @["isnimbleproject", "getmpdalbumart", "kaksource", "randfile"]


# Dependencies

requires "nim >= 0.19.4","libmpdclient"
