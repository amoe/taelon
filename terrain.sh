#!/bin/sh

prgname=terrain

main() {
    test $# -ne 2 && die "usage: terrain <game dir> <terrain zip>"

    # cat update.cfg >> packman.cfg
}

die() {
    echo "${prgname}: $@" >&2
    exit 1
}

main "$@"
