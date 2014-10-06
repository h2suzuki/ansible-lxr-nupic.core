#!/bin/bash

# file: roles/lxr/tree_retrieval/files/lxrconf_mod_version.sh

usage()
{
    echo "Usage: `basename $0` <lxr.conf> {add|delete} <version>" >&2
}

[ $# -ne 3 ] && { usage; exit 1; }
[ ! -r "$1" ] && { echo "Cannot read the config file: $1" >&2; exit 1; }
case "$2" in
    add) MODE=1 ;;
    delete) MODE=0 ;;
    *) usage; exit 1 ;;
esac

TMPFILE="`mktemp "$1".XXXXXXXX`" || exit 2
trap 'rm -f "$TMPFILE"' 0

awk '
    BEGIN         {in_range=0}

    in_range==0   {print}
    in_range==1   {if ($1!=VERSION) print}  /* exclude duplcates */

    /range.*\qw/  {in_range=1; if (ADD) printf("\t\t\t\t\t%s\n",VERSION)}
    /)]/          {in_range=0}

' VERSION="$3" ADD="$MODE" "$1" > "$TMPFILE" || exit 3

[ -s "$TMPFILE" ] || exit 4

cmp -s "$1" "$TMPFILE"
case "$?" in
  0) echo '"changed:" false';;
  1) echo '"changed:" true';;
  *) echo 'some error occurred'; exit 5;;
esac

# commit the changes
chmod --reference "$1" "$TMPFILE" &&
ln -f "$1" "$1.bak" &&
mv -f "$TMPFILE" "$1"
