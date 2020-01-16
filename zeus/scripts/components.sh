source "zeus/scripts/common.sh"

cd "${build_dir}"

sudo chmod a+w eopkg-index.xml*
sed -i '$ d' eopkg-index.xml
find ../src -maxdepth 1 -type d -name \*.\* -printf "%f\n" | while read comp; do
    comp_group="$(awk -F'.' '{print $1}' <<< "${comp}")"
    cat >> eopkg-index.xml <<EOF
    <Component>
        <Name>${comp}</Name>
        <Group>${comp_group}</Group>
        <Maintainer>
            <Name>${pkgr_name}</Name>
            <Email>${pkgr_email}</Email>
        </Maintainer>
    </Component>
EOF
done

echo "</PISI>" >> eopkg-index.xml
sha1sum eopkg-index.xml | awk '{print $1}' > eopkg-index.xml.sha1sum
xz -kf eopkg-index.xml
sha1sum eopkg-index.xml.xz | awk '{print $1}' > eopkg-index.xml.xz.sha1sum
