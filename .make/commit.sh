#!/bin/bash

git status -s | awk '/package.yml$/ {print $2}' | while read -r p_yml; do
    p_comp="$(awk -F'/' 'BEGIN {OFS="."} {$1=""; NF=NF-2; print}' <<<"${p_yml}" | cut -c 2-)"
    p_name="$(awk -F'/' '{print $(NF-1)}' <<<"${p_yml}")"
    p_ver="$(git --no-pager diff "${p_yml}" | grep ^+version | awk '{print $3}')"
    msg="bump"; [ -n "${p_ver}" ] && msg="update to ${p_ver}"
    if [ -n "${p_comp}" ] && [ -n "${p_name}" ]; then
        git add "$(dirname "${p_yml}")"
        git commit -m "${p_comp}: ${p_name}: ${msg}" 
    fi
done
