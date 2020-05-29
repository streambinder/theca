#!/usr/bin/env python3

import glob
import os

from common import series

for eopkg in series():
    for subpkg in [eopkg.name] + eopkg.subpackages:
        for package in glob.glob(os.path.join(os.environ['BUILD_DIR'], subpkg + '-*')):
            version = package.split('-')[-4]
            release = int(package.split('-')[-3])
            name = os.path.basename(package.split(
                '-{}-{}'.format(version, release))[0])
            if name == subpkg and (version != eopkg.version or release != eopkg.release):
                print('Stripping out', package)
                os.remove(package)
