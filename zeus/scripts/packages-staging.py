#!/usr/bin/env python3

import subprocess
import sys

from common import Eopkg, get_series, solbuild

yml_updated = []
tag = subprocess.Popen(
    ['git', 'describe', '--tags', '--abbrev=0'],
    stdout=subprocess.PIPE).communicate()[0].strip()
yml_from_tag = list(
    map(lambda fname: (Eopkg(fname)),
        filter(lambda fname: (fname.endswith('package.yml')),
               subprocess.Popen(['git', 'diff', '--name-only', 'HEAD', tag],
                                stdout=subprocess.PIPE).communicate()[0].strip().splitlines())))
for group in get_series():
    for group_id in group:
        for package_name in group[group_id]:
            for package_updated in yml_from_tag:
                if package_name == package_updated.name:
                    yml_updated.append(package_updated)

for eopkg in yml_updated:
    print('Building {} ({})'.format(eopkg.name, eopkg.version))
    if not solbuild(eopkg):
        print('Build failed')
        sys.exit(1)
