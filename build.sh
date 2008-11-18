#! /bin/sh

prgname=build

main() {
    test $# -ne 2 && die "exactly two arguments required"

    game="$1/dark"
    zip=$2

    building=$(basename "$zip" .zip)

    tmp=$(mktemp -d)
    unzip -qd "$tmp" "$zip"
    lc "$tmp"/*

    addon="$game/addon/$building"
    scenario="$game/scenario/single/$building"

    mkdir -p "$addon" "$scenario"

    cp "${tmp}/${building}.ftg" "${tmp}/${building}.cfg" "$addon"

    cp "${tmp}/${building}.map" "${tmp}/${building}.scn" "${tmp}/tactics.mm" \
      "${tmp}/packman.cfg" "${tmp}/mlstring.cfg" \
      "$scenario"

    test -e "${tmp}/units.txt" && cp "${tmp}/units.txt" "$scenario"
    test -e "${tmp}/animate.txt" && cp "${tmp}/animate.txt" "$scenario"
    test -e "${tmp}/weapon.txt" && cp "${tmp}/weapon.txt" "$scenario"
    test -e "${tmp}/build.txt" && cp "${tmp}/build.txt" "$scenario"
    test -e "${tmp}/ovleff.txt" && cp "${tmp}/ovleff.txt" "$scenario"

    rm -r "$tmp"
}


lc() {
    for file; do
        dir=$(dirname "$file")
        name=$(basename "$file")


        new=$(echo "$name" | tr "[:upper:]" "[:lower:]")

        if [ "$new" != "$name" ]; then
            mv -i "$file" "${dir}/${new}"
        fi
    done
}


die() {
    echo "${prgname}: $@" >&2
    exit 1
}

main "$@"
