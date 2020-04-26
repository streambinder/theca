#!/usr/bin/env python3

import glob
import os
import subprocess
import sys
import threading

from _common import Eopkg, get_series, solbuild

for group in get_series():
    for group_id in group:
        print('Building packages from {}...'.format(group_id))

        for package in group[group_id]:
            package_yml, _ = subprocess.Popen(['egrep', '-rl', '^name\\s+:\\s+{}$'.format(
                package), 'src'], stdout=subprocess.PIPE).communicate()
            package_yml = package_yml.strip()
            if len(package_yml) == 0:
                print('Package manifest for {} not found'.format(package))
                continue

            eopkg = Eopkg(package_yml)
            if len(glob.glob(os.path.join('bin', eopkg.glob()))) > 0:
                # print('Package {}-{} up to date'.format(package, package_version))
                continue

            print('Building {}'.format(eopkg.name))
            if not solbuild(eopkg):
                print('Build failed')
                sys.exit(1)

subprocess.Popen(['sudo', 'solbuild', 'index'], cwd='bin').communicate()
