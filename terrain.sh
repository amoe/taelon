#! /bin/sh

prgname=terrain

# Two different methods:
# 'update.cfg' method is used for aust.zip and volcanic.zip

main() {
    test $# -ne 2 && die "exactly two arguments required"

    game="$1/dark"
    zip=$2

    terrain=$(basename "$zip" .zip)

    tmp=$(mktemp -d)
    unzip -qd "$tmp" "$zip"
    lc "$tmp"/*

    addon="$game/addon/$terrain"
    mkdir -p "$addon"

    cp "${tmp}/${terrain}.ftg" "${tmp}/packman.cfg" "$addon"
    cat "${tmp}/update.cfg" >> "$game/packman.cfg"

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
