#!/bin/sh

prgname=combo

main() {
    test $# -eq 0 && { usage; exit 1; }
    
    cmd=$1
    shift

    case "$cmd" in
        install)    install "$@" ;;
        uninstall)  uninstall "$@" ;;
        *) die "unknown subcommand '$cmd'" ;;
    esac
}


install() {
    # algo:
    # extract
    # backup
    # copy_new

    test $# -ne 2 && die "install: exactly two arguments required"

    game="$1/dark"
    zip=$2

    unzip -qqd "$game/addon/auran" "$zip"
    mkdir "$game/addon/auran/backup"
    cp -p "$game/packman.cfg" "$game/addon/auran/backup"
    cp "$game/addon/auran/standard/PACKMAN.CFG" "$game/packman.cfg"

    echo "combo pack installed."
}

uninstall() {
    test $# -ne 1 && die "uninstall: exactly one argument required"

    game="$1/dark"

    test -d "$game/addon/auran" || die "uninstall: combo pack isn't installed"

    cp -p "$game/addon/auran/backup/packman.cfg" "$game/packman.cfg"
    rm -r "$game/addon/auran"

    echo "combo pack uninstalled."
}


die() {
    echo "${prgname}: $@" >&2
    exit 1
}


usage() {
    echo "Usage: combo [COMMAND] [ARGUMENTS]

Valid COMMANDs are:
    install      install the combo pack
    uninstall    uninstall the combo pack

Example:
    # Install the combo pack
    combo install win/programs/dkreign combo3.exe
    
    # Revert to the default game
    combo uninstall win/programs/dkreign

Enjoy."
}


main "$@"
