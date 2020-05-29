#!/usr/bin/env python3

import glob
import os
import subprocess
import sys
import threading

from common import series, sol_build, sol_index

for eopkg in series():
    if len(glob.glob(os.path.join(os.environ['BUILD_DIR'], eopkg.glob()))) > 0 or len(glob.glob(os.path.join(os.environ['BUILD_DIR'], eopkg.subglob()))) > 0:
        continue

    print('Building {}'.format(eopkg.name))
    if not sol_build(eopkg):
        print('Unable to build {}'.format(eopkg.name))
        sys.exit(1)

sol_index(os.environ['BUILD_DIR'])
