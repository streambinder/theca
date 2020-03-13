cd "${build_dir}"

grep -v ^\# ../src/series | while read pkg_name; do
    pkg="$(dirname $(egrep -rl "^name\s+:\s+${pkg_name}$" ../src))"
    if [ -z "${pkg}" ]; then
        echo "Package ${pkg_name} not found"
        continue
    fi

    pkg_version="$(awk -F': ' '/^version/ {print $2}' "${pkg}/package.yml")"
    pkg_release="$(awk -F': ' '/^release/ {print $2}' "${pkg}/package.yml")"
    if [ -f "${pkg_name}-${pkg_version}-${pkg_release}-"*".eopkg" ]; then
        # echo "Package ${pkg_name} up-to-date"
        continue
    fi
      
    echo "Compiling ${pkg_name}"
    sudo solbuild build "${pkg}/package.yml" > /dev/null 2>&1 || \
        echo "Unable to compile ${pkg_name}!"
done

rm -f *.xml
sudo solbuild index > /dev/null 2>&1
