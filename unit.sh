#! /bin/sh

prgname=unit

# weird cases: gore, zenn, kylguard
# gore.zip is handled
# fanblade.exe can be extracted directly to $game

main() {
    test $# -ne 2 && die "exactly two arguments required"

    game="$1/dark"
    zip=$2

    unit=$(basename "$zip" .zip)

    tmp=$(mktemp -d)
    unzip -qd "$tmp" "$zip"
    lc "$tmp"/*

    addon="$game/addon/$unit"
    scenario="$game/scenario/single/$unit"

    mkdir -p "$addon" "$scenario"

    cp "${tmp}/${unit}.ftg" "${tmp}/${unit}.cfg" "$addon"
    # optional: gore
    test -e "${tmp}/${unit}sfx.ftg" && cp "${tmp}/${unit}sfx.ftg" "$addon"

    cp "${tmp}/${unit}.map" "${tmp}/${unit}.scn" "${tmp}/tactics.mm" \
      "${tmp}/packman.cfg" "${tmp}/mlstring.cfg" \
      "$scenario"

    test -e "${tmp}/units.txt" && cp "${tmp}/units.txt" "$scenario"
    test -e "${tmp}/animate.txt" && cp "${tmp}/units.txt" "$scenario"
    test -e "${tmp}/weapon.txt" && cp "${tmp}/units.txt" "$scenario"

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
