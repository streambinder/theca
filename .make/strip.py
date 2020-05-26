#!/usr/bin/env python3

import glob
import os

from common import series

for eopkg in series():
    for package in glob.glob(os.path.join(os.environ['BUILD_DIR'], eopkg.name + '-*')):
        version = package.split('-')[-4]
        release = int(package.split('-')[-3])
        name = package.split('-{}-{}'.format(version, release))[0]
        if name == eopkg.name and (version != eopkg.version or release != eopkg.release):
            print('Stripping out', package)
            os.remove(package)
