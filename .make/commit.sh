#!/bin/bash

git status -s | awk '/package.yml$/ {print $2}' | while read -r p_yml; do
    p_comp="$(awk -F'/' 'BEGIN {OFS="."} {$1=""; NF=NF-1; print}' <<<"${p_yml}" | cut -c 2-)"
    p_name="$(awk -F'/' '{print $(NF-1)}' <<<"${p_yml}")"
    p_ver="$(awk '/^version/ {print $3}' <"${p_yml}")"
    if [ -n "${p_comp}" ] && [ -n "${p_name}" ] && [ -n "${p_ver}" ]; then
        git commit -m "${p_comp}: ${p_name}: update to ${p_ver}" "${p_yml}"
    fi
done
