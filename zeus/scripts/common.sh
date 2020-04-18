#!/bin/bash

pkgr_name="$(awk -F'=' '/^Name/ {print $2}' ${HOME}/.solus | xargs)"
pkgr_email="$(awk -F'=' '/^Email/ {print $2}' ${HOME}/.solus | xargs)"
