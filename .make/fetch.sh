#!/bin/bash

cd "${BUILD_DIR}"

curl -s "https://api.github.com/repos/streambinder/theca/releases" \
        | jq -r '.[0].assets[].browser_download_url' \
        | parallel -j "${J:-1}" wget -nc -q