#!/usr/bin/env python3

import glob
import os
import subprocess
import sys
import threading

from common import Eopkg, get_series, solbuild, ReturningThread

workers = []
max_workers = 10
if 'MAX_WORKERS' in os.environ:
    max_workers = int(os.environ['MAX_WORKERS'])

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

            worker = ReturningThread(target=solbuild, args=(eopkg,))
            print('Building {}'.format(eopkg.name))
            worker.start()
            if len(workers) < max_workers:
                workers.append(worker)
            else:
                if not worker.join():
                    print('Build failed')
                    sys.exit(1)

        while len(workers) > 0:
            print('Group workers left: {}'.format(len(workers)))
            if not workers.pop().join():
                print('Build failed')
                sys.exit(1)

subprocess.Popen(['sudo', 'solbuild', 'index'], cwd='bin').communicate()
