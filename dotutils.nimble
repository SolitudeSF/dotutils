# Package

version       = "0.1.6"
author        = "SolitudeSF"
description   = "Helper programs for my own workflow"
license       = "MIT"
srcDir        = "src"
bin           = @["getprojecticon", "getmpdalbumart", "randfile", "wlp", "chext", "fsfree", "gamescope_args", "cnvrt", "xwinlayout", "dircount", "clipmon"]


# Dependencies

requires "nim >= 2.0.0", "mpdclient >= 0.1.5", "xcb >= 0.2.1", "cligen >= 1.7.0"
