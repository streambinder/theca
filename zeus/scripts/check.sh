find src -type f -name 'package.yml' | sort -u | while read -r pkg; do
    pkg_name="$(awk -F': ' '/^name/ {print $2}' < "${pkg}")"
    pkg_version="$(awk -F': ' '/^version/ {print $2}' < "${pkg}")"
    pkg_src="$(awk '/^\s+/ {print $2}' < "${pkg}" | head -1)"
    pkg_version_new="$(cuppa q "${pkg_src}" | awk '{print $1}')"

    [ "${pkg_version}" != "${pkg_version_new}" ] && \
        [ "${pkg_version_new}" != "🕱" ] && \
        echo "${pkg_name}: ${pkg_version_new}" || echo -n
done
