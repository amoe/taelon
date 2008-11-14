#!/bin/sh

prefix=/usr/local
prgname=taelon

# "ik heb genoeg matisse"

main() {
    test $# -eq 0 && { usage; exit 1; }
    
    command=$1
    path="${prefix}/lib/taelon/$1"
    shift

    if [ -x "$path" ]; then
        exec "$path" "$@"
    else
        die "subcommand '$command' failed to execute"
    fi
}


usage() {
    echo "Usage: taelon COMMAND [OPTIONS]
taelon gives you power in Dark Reign.

Commands:
    pak        create pak archives
    paklist    list the contents of pak archives
    terr       manipulate the terrorists side
    unit       install downloadable units
    unpack     unpack pak archives
    combo      manipulate the combo pack

Enjoy."
}

die() {
    echo "${prgname}: $@" >&2
    exit 1
}

main "$@"

