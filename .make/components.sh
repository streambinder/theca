#!/bin/bash

cd "${BUILD_DIR}" || exit 1

sudo chmod a+w eopkg-index.xml*
sed -i '$ d' eopkg-index.xml
find ../src -type f -name component.xml | while read -r comp; do
    awk '{ print "    "$0 }' "${comp}" >> eopkg-index.xml
done

echo "</PISI>" >> eopkg-index.xml
sha1sum eopkg-index.xml | awk '{print $1}' > eopkg-index.xml.sha1sum
xz -kf eopkg-index.xml
sha1sum eopkg-index.xml.xz | awk '{print $1}' > eopkg-index.xml.xz.sha1sum
