#!/usr/bin/env python3

import glob
import os
import subprocess
import yaml

from threading import Thread


class ReturningThread(Thread):
    def __init__(self, group=None, target=None, name=None, args=(), kwargs=None, daemon=None):
        Thread.__init__(self, group, target, name, args, kwargs, daemon=daemon)
        self._return = None

    def run(self):
        if self._target is not None:
            self._return = self._target(*self._args, **self._kwargs)

    def join(self):
        Thread.join(self)
        return self._return


class Eopkg(object):
    def __init__(self, yml):
        self.name = ""
        self.version = ""
        self.release = ""
        self.yml = yml
        self._parse()

    def _parse(self):
        with open(self.yml, 'r') as yml_fd:
            try:
                pkg_yml = yaml.safe_load(yml_fd)
                self.name = pkg_yml['name']
                self.version = pkg_yml['version']
                self.release = pkg_yml['release']
            except yaml.YAMLError as e:
                raise e

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
        return False
    finally:
        log.close()

    packages = glob.glob(os.path.join(
        os.path.dirname(eopkg.yml), '*.eopkg'))
    if len(packages) == 0:
        print('Unable to build {}'.format(eopkg.name))
        return False

    for package in packages:
        os.rename(package, os.path.join('bin', os.path.basename(package)))
    for pspec in glob.glob(os.path.join(
            os.path.dirname(eopkg.yml), '*.xml')):
        os.remove(pspec)

    return True


def get_series():
    with open('src/series', 'r') as series_fd:
        try:
            return yaml.safe_load(series_fd)
        except yaml.YAMLError as e:
            print(e)
