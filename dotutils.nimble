# Package

version       = "0.1.0"
author        = "SolitudeSF"
description   = "Helper programs for my own workflow"
license       = "MIT"
srcDir        = "src"
bin           = @["isnimbleproject", "getmpdalbumart", "kaksource"]


# Dependencies

requires "nim >= 0.19.4","libmpdclient"
