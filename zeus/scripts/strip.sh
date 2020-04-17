cd bin

find -name \*\.eopkg | while read pkg; do
    pkg_pts="$(sed 's/\.eopkg//g' <<< "${pkg}")" 
    pkg_arch="$(awk -F'-' '{print $NF}' <<< "${pkg_pts}")"
    pkg_pts="$(sed "s/-1-${pkg_arch}$//g" <<< "${pkg_pts}")"
    pkg_release="$(awk -F'-' '{print $NF}' <<< "${pkg_pts}")"
    pkg_pts="$(sed "s/-${pkg_release}$//g" <<< "${pkg_pts}")"
    pkg_version="$(awk -F'-' '{print $NF}' <<< "${pkg_pts}")"
    pkg_name="$(sed "s/-${pkg_version}$//g" <<< "${pkg_pts}" | sed 's/^\.\///g')"
    
    ls *eopkg | egrep -e "^${pkg_name}-[0-9\.]+" | sort -u | head -n -1 \
        | while read pkg_dup; do
        rm -vf "${pkg_dup}"
    done
done
