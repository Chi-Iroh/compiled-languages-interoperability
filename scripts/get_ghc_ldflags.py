#!/bin/env python3

import os
import sys

if __name__ == "__main__":
    file = sys.argv[1]
    ghc_ldflags = [arg.strip() for arg in open(file[1:], "r").readlines()]

    _len = len(ghc_ldflags)
    i = 0

    while i < _len:
        if ghc_ldflags[i] == '"-o"':
            del ghc_ldflags[i + 1] # xxx (executable name)
            del ghc_ldflags[i] # "-o"
            _len -= 2
        elif ghc_ldflags[i].endswith('.o"'):
            del ghc_ldflags[i] # xxx.o (object file name)
            _len -= 1
        i += 1

    output = os.getenv("GHC_LDFLAGS_OUTPUT")
    if output is None:
        output = "ghc_ldflags.log"

    open(output, "w").write(" ".join(ghc_ldflags))
