#!/bin/sh

prgname=terr

terr99rc2_cksum=1521926028

# goes in dark/deftxt
deftxt="animate.txt
build.txt
damage.txt
overlay.txt
ovleff.txt
trneff.txt
units.txt
weapon.txt"

# these all need to be prefixed with 'ex' later on
deftxtex="animate.txt
build.txt
damage.txt
general.txt
overlay.txt
ovleff.txt
trneff.txt
units.txt
weapon.txt"

# goes in dark/local
local="mlstring.cfg
gamemsg.txt"

# goes in dark/
dark="packman.cfg"

# goes in dark/aip
aip="def_00_0.fsm
def_00_1.fsm
def_00_2.fsm
def_01_0.fsm
def_01_1.fsm
def_01_2.fsm
def_02_0.fsm
def_02_1.fsm
def_02_2.fsm
def_03_0.fsm
def_03_1.fsm
def_03_2.fsm
fdeasy1.aip
fdeasy2.aip
fdhar1.aip
fdhar2.aip
fdhar3.aip
fdhdef.aip
fdhoff.aip
fdmed1.aip
fdmed2.aip
fdrush.aip
fgattack.fsm
fgdbase.aip
fgdefend.fsm
fgdper.aip
fgeven1.aip
fgeven2.aip
fgeven.fsm
fgspecal.fsm
ideasy1.aip
ideasy2.aip
idhar1.aip
idhar2.aip
idhar3.aip
idhdef.aip
idhoff.aip
idmed1.aip
idmed2.aip
idrush.aip
impeven1.aip
impeven2.aip
ipattack.fsm
ipdbase.aip
ipdefend.fsm
ipdper.aip
ipeven.fsm
ipspecal.fsm
tattack.fsm
tdbase.aip
tdeasy1.aip
tdeasy2.aip
tdefend.fsm
tdhar1.aip
tdhar2.aip
tdhar3.aip
tdmed1.aip
tdmed2.aip
tdper.aip
teven1.aip
teven2.aip
teven.fsm
tspecial.fsm"

# goes in dark/addon/terr
terr="terr.cfg
terr.ftg"


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
    tmpdir=$(mktemp -td terr-XXXXXXXXXX)

    extract "$zip" "$tmpdir"
    backup
    copy_new "$tmpdir"
    cleanup "$tmpdir"

    echo "terrorists installed."
}


backup() {
    backup_dir="${game}/addon/terr/backup"
    echo "backing up old files: '$backup_dir'"

    mkdir -p \
      "$backup_dir"/deftxt \
      "$backup_dir"/deftxtex \
      "$backup_dir"/local \
      "$backup_dir"/aip
    

    for f2 in $deftxt; do
        cp -ip "${game}/deftxt/$f2" "${backup_dir}/deftxt"
    done

    for f2 in $deftxtex; do
        cp -ip "${game}/deftxtex/$f2" "${backup_dir}/deftxtex"
    done

    for f2 in $local; do
        cp -ip "${game}/local/$f2" "${backup_dir}/local"
    done

    for f2 in $dark; do
        cp -ip "${game}/$f2" "${backup_dir}"
    done

    for f2 in $aip; do
        cp -ip "${game}/aip/$f2" "${backup_dir}/aip"
    done
}


copy_new() {
    echo "copying new files for terrorists"

    tmpdir=$1

    for f2 in $deftxtex; do
        cp -fp "${tmpdir}/ex${f2}" "${game}/deftxtex/$f2"
    done

    for f2 in $deftxt; do
        cp -fp "${tmpdir}/${f2}" "${game}/deftxt/$f2"
    done

    for f2 in $local; do
        cp -fp "${tmpdir}/${f2}" "${game}/local/$f2"
    done

    for f2 in $aip; do
        cp -fp "${tmpdir}/${f2}" "${game}/aip/$f2"
    done

    # and special-case the root
    cp -fp "${tmpdir}/packman.ter" "${game}/packman.cfg"

    # now install the terrorist paks
    cp -fp "${tmpdir}/terr.cfg" "${tmpdir}/terr.ftg" "${game}/addon/terr"
}


extract() {
    zip=$1
    tmpdir=$2
    
    if ! verify "$zip"; then
        die "incorrect checkum on '$zip', it may be corrupted"
    else
        echo "validated checksum on '$zip'"
    fi
    
    test -d "${game}/addon/terr" \
        && die "previous installation found, bailing out"
    
    unzip -qd "$tmpdir" "$zip"
    lc "$tmpdir"/*
}


cleanup() {
    dir=$1
    rm -r "$dir"
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


verify() {
    for file; do
        checksum=$(cksum "$file" | cut -d ' ' -f 1)
        test "$checksum" = "$terr99rc2_cksum"
    done
}


uninstall() {
    test $# -ne 1 && die "uninstall: exactly one argument required"
    
    game="$1/dark"

    # setup $game from "$@"
    # call restore
    # call remove

    restore
    remove

    echo "terrorists uninstalled."
}


restore() {
    backup_dir="${game}/addon/terr/backup"
    test ! -d "$backup_dir" && die "no backup present, cannot restore"

    echo "restoring backup"

    for f2 in $deftxt; do
        cp -fp "${backup_dir}/deftxt/$f2" "${game}/deftxt"
    done

    for f2 in $deftxtex; do
        cp -fp "${backup_dir}/deftxtex/$f2" "${game}/deftxtex"
    done

    for f2 in $local; do
        cp -fp "${backup_dir}/local/$f2" "${game}/local"
    done

    for f2 in $dark; do
        cp -fp "${backup_dir}/$f2" "${game}"
    done

    for f2 in $aip; do
        cp -fp "${backup_dir}/aip/$f2" "${game}/aip"
    done
}


remove() {
    echo "removing terrorist files"
    
    # basically just remove addon/terr
    rm -rf "${game}/addon/terr"
}


die() {
    echo "${prgname}: $@" >&2
    exit 1
}


usage() {
    echo "Usage: terr [COMMAND] [ARGUMENTS]

Valid COMMANDs are:
    install      install the terrorist side
    uninstall    revert to the tograns from a backup

Example:
    # Install the Terrorists
    terr install win/programs/dkreign terr99rc2.exe
    
    # Now go back to the Tograns
    terr uninstall win/programs/dkreign

Enjoy."
}


main "$@"
