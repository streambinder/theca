#!/bin/bash

cd "${BUILD_DIR}"

curl -s "https://api.github.com/repos/streambinder/theca/releases" \
        | jq -r '.[0].assets[].browser_download_url' | while read -r asset; do
    asset_name="$(awk -F'/' '{print $NF}' <<< "${asset}")"
    [ ! -f "${asset_name}" ] && \
        echo "Downloading ${asset_name}" && \
        wget -q "${asset}" || echo -n
done
