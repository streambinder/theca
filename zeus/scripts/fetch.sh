#!/bin/bash

cd bin

curl -s https://api.github.com/repos/streambinder/theca/releases \
        | jq '.[0].assets[] | .browser_download_url' | sed 's/"//g' \
        | while read -r asset; do
    asset_name="$(awk -F'/' '{print $NF}' <<< "${asset}")"
    [ ! -f "${asset_name}" ] && \
        echo "Downloading ${asset_name}" && \
        wget -q "${asset}" || echo -n
done
