#!/usr/bin/env python3

import glob
import os
import subprocess
import threading
import yaml


class Eopkg(object):
    def __init__(self, name, version, release, yml):
        self.name = name
        self.version = version
        self.release = release
        self.yml = yml

    def glob(self):
        return '{}-{}-{}-*.eopkg'.format(self.name, self.version, self.release)


def solbuild(eopkg):
    log = open(eopkg.yml.replace('yml', 'log'), 'w')
    try:
        subprocess.Popen(['sudo', 'solbuild', 'build', 'package.yml'], cwd=os.path.dirname(
            eopkg.yml), stdout=log, stderr=subprocess.STDOUT).communicate()
    except subprocess.CalledProcessError as e:
        print('Unable to build {}: [{}] {}'.format(
            eopkg.name, e.returncode, e.output))
    finally:
        log.close()

    if len(glob.glob(os.path.join('bin', eopkg.glob()))) == 0:
        print('Unable to build {}'.format(eopkg.name))
    else:
        print('{} built'.format(eopkg.name))


with open('src/series', 'r') as series_fd:
    try:
        series = yaml.safe_load(series_fd)
    except yaml.YAMLError as e:
        print(e)

workers = []
for group in series:
    for group_id in group:
        print('Building packages from {}...'.format(group_id))

        for package in group[group_id]:
            pipe_package_yml, _ = subprocess.Popen(['egrep', '-rl', '^name\\s+:\\s+{}$'.format(
                package), 'src'], stdout=subprocess.PIPE).communicate()
            package_yml = pipe_package_yml.strip()
            if len(package_yml) == 0:
                print('Package manifest for {} not found'.format(package))
                continue

            pipe_package_version, _ = subprocess.Popen(
                ['awk', '-F:', '/^version/ {print $2}', package_yml], stdout=subprocess.PIPE).communicate()
            package_version = pipe_package_version.strip()
            if len(package_version) == 0:
                print('Unable to parse {} version'.format(package))
                continue

            pipe_package_release, _ = subprocess.Popen(
                ['awk', '-F:', '/^release/ {print $2}', package_yml], stdout=subprocess.PIPE).communicate()
            package_release = pipe_package_release.strip()
            if len(package_release) == 0:
                print('Unable to parse {} release'.format(package))
                continue

            eopkg = Eopkg(package, package_version,
                          package_release, package_yml)
            if len(glob.glob(os.path.join('bin', eopkg.glob()))) > 0:
                print('Package {}-{} up to date'.format(package, package_version))
                continue

            worker = threading.Thread(
                target=solbuild, args=(eopkg,))
            print('Building {}'.format(eopkg.name))
            worker.start()
            if len(workers) > 10:
                worker.join()
            else:
                workers.append(worker)

        while len(workers) > 0:
            print('Group workers left: {}'.format(len(workers)))
            workers.pop().join()

subprocess.Popen(['sudo', 'solbuild', 'index'], cwd='bin').communicate()
