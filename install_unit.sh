#!/bin/sh

lc() {
    for file; do
        dir=$(dirname "$file")
        name=$(basename "$file")


        new=$(echo "$name" | tr "[:upper:]" "[:lower:]")

        if [ "$new" != "$name" ]; then
            mv -iv "$file" "${dir}/${new}"
        fi
    done
}

path=$1
zip=$2

tmp=$(mktemp -d)
unzip -d "$tmp" "$zip"
lc "$tmp"/*

name=$(basename "$zip" .zip)
addon="${path}/dark/addon/${name}"
scenario="${path}/dark/scenario/single/${name}"

mkdir -pv "$addon" "$scenario"

cp -v "${tmp}/${name}.ftg" "${tmp}/${name}.cfg" "$addon"

cp -v "${tmp}/${name}.map" "${tmp}/${name}.scn" "${tmp}/tactics.mm" \
      "${tmp}/packman.cfg" "${tmp}/mlstring.cfg" \
    "$scenario"

echo "That's it!"

rm -rv "$tmp"
