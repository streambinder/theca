#!/bin/bash

# check build dir
if [ -z "${BUILD_DIR}" ]; then
    echo "Missing build dir"
    exit 1
fi

# check token
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Missing token"
    exit 1
fi

# check release variant
if [ -z "${VARIANT}" ]; then
    VARIANT=unstable
fi

# params
GITHUB_REPO="streambinder/theca"
HEADER_TOKEN="Authorization: token ${GITHUB_TOKEN}"

# get release id
VARIANT_ID="$(curl -s -H "${HEADER_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${VARIANT}" | jq '.id')"
if [ -z "${VARIANT_ID}" ]; then
    echo "Unable to get release id"
    exit 1
fi

# upload files
for fname in "${BUILD_DIR}"/*; do
    echo "Uploading $(basename ${fname})..."
    response="$(curl -s --data-binary @"${fname}" -H "${HEADER_TOKEN}" -H "Content-Type: application/octet-stream" \
        "https://uploads.github.com/repos/${GITHUB_REPO}/releases/${VARIANT_ID}/assets?name=$(basename ${fname})")"
    error="$(jq '.errors[0].code' <<< ${response} | sed 's/"//g' | grep -v null)"
    if [ -z "${error}" ]; then
        echo "Upload ok"
    else
        echo "Error: ${error}"
    fi
done