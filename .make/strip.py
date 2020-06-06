#!/usr/bin/env python3

import sys
import glob
import os

from common import series


series_flat = dict()
for eopkg in series():
    series_val = (eopkg.version, eopkg.release)
    series_flat[eopkg.name] = series_val
    for subeopkg in eopkg.subpackages:
        series_flat[subeopkg] = series_val

for package in glob.glob(os.path.join(os.environ['BUILD_DIR'], '*.eopkg')):
    version = package.split('-')[-4]
    release = int(package.split('-')[-3])
    name = os.path.basename(package.split(
        '-{}-{}'.format(version, release))[0])

    reason = None
    if name not in series_flat:
        reason = 'deprecated'
    elif (version, release) != series_flat[name]:
        reason = 'outdated'

    if reason is not None:
        print('Stripping', reason, '{}-{}-{}'.format(name, version, release), 'out')
        os.remove(package)
