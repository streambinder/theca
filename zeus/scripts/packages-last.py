#!/usr/bin/env python3

import subprocess

from common import Eopkg, get_series, solbuild

eopkg_updated = []
eopkg_updated_sort = []
yml_updated, _ = subprocess.Popen(
    ['git', 'diff-tree', '--no-commit-id', '-r', 'HEAD'],
    stdout=subprocess.PIPE).communicate()

for package_yml in yml_updated.splitlines():
    eopkg_updated.append(Eopkg(package_yml))

for group in get_series():
    for group_id in group:
        for package_name in group[group_id]:
            for package_updated in eopkg_updated:
                if package_name == package_updated.name:
                    eopkg_updated_sort.append(package_updated)

for eopkg in eopkg_updated_sort:
    solbuild(eopkg)
