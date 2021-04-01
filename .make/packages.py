#!/usr/bin/env python3

import glob
import os
import subprocess
import sys
import threading

from common import series, sol_build, sol_index, sol_sweep

for eopkg in series():
    if len(glob.glob(os.path.join(os.environ['BUILD_DIR'], eopkg.glob()))) > 0 or len(glob.glob(os.path.join(os.environ['BUILD_DIR'], eopkg.subglob()))) > 0:
        continue

    print('Building {}'.format(eopkg.name))
    if not sol_build(eopkg):
        print('Unable to build {}'.format(eopkg.name))
        with open(eopkg.yml.replace('package.yml', os.environ['BUILD_LOG']), 'r') as log:
            print(log.read())
        sys.exit(1)

    if 'SWEEP' in os.environ:
        print('Cleaning up solbuild cache')
        sol_sweep()

sol_index(os.environ['BUILD_DIR'])
