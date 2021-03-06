#!/usr/bin/env python3

import sys

from common import series

for eopkg in sorted(series(), key=lambda eopkg: eopkg.name):
    try:
        eopkg.check()
        print('Package {} check ok'.format(eopkg.name))
    except Exception as e:
        sys.exit('Package {} check ko: {}'.format(eopkg.name, str(e)))
