#!/bin/bash

function curl_handle {
    curl_error="$(jq -r '.errors[0].message' <<< "$@")"
    if [ "${curl_error}" != "" ] && [ "${curl_error}" != "null" ]; then
        echo "Error: ${curl_error}"
    fi
}

function upload {
    asset_fname="$(awk -F':' '{print $1}' <<< "$@")"
    echo "Uploading ${asset_fname} to ${VARIANT} upstream..."
    curl_handle "$(curl -s --data-binary @"${asset_fname}" -H "${HEADER_TOKEN}" -H "Content-Type: application/octet-stream" \
        "https://uploads.github.com/repos/${GITHUB_REPO}/releases/${VARIANT_ID}/assets?name=$(basename ${asset_fname})")"
}

function delete {
    asset_fname="$(awk -F':' '{print $1}' <<< "$@")"
    asset_id="$(grep ":$@$" <<< "${VARIANT_ASSETS}" | awk -F':' '{print $1}')"
    if [ -z "${asset_id}" ]; then
        echo "Unable to get asset id for $@"
        return
    fi

    echo "Deleting ${asset_fname} (${asset_id}) from ${VARIANT} upstream..."
    curl_handle "$(curl -X DELETE -s -H "${HEADER_TOKEN}" "https://api.github.com/repos/${GITHUB_REPO}/releases/assets/${asset_id}")"
}

cd "${BUILD_DIR}"

# check token
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Missing token"
    exit 1
fi

# check release variant
if [ -z "${VARIANT}" ]; then
    VARIANT=unstable
fi

# check sync type
if [ -z "${HARD}" ] || [ "${HARD}" != "1" ]; then
    HARD=0
fi

# params
GITHUB_REPO="streambinder/theca"
HEADER_TOKEN="Authorization: token ${GITHUB_TOKEN}"

# get release current status
VARIANT_STRUCT="$(curl -s -H "${HEADER_TOKEN}" "https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${VARIANT}")"
VARIANT_ID="$(jq -r '.id' <<< "${VARIANT_STRUCT}")"
if [ -z "${VARIANT_ID}" ]; then
    echo "Unable to get release id"
    exit 1
fi

# synchronize
VARIANT_ASSETS="$(jq -r '.assets[] | [ .id, .name, .size|tostring ] | join(":")' <<< "${VARIANT_STRUCT}")"
VARIANT_DIFF="$(diff <(awk -F':' '{print $2":"$3}' <<< "${VARIANT_ASSETS}") \
    <(du -b * | awk -v hard="${HARD}" '{if (hard || substr($2, 0, 15) == "eopkg-index.xml") { $1 = "0" }; print}' | awk '{print $2":"$1}'))"
while read -r op; do
    case ${op:0:1} in
        '<')
            delete "$(awk '{print $2}' <<< "${op}")"
            ;;
        '>')
            upload "$(awk '{print $2}' <<< "${op}")"
            ;;
        *)
    esac
done <<< "${VARIANT_DIFF}"