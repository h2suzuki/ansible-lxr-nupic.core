#!/bin/bash

# file: roles/lxr/files/lxrconf_show_version.sh

usage()
{
    echo "Usage: `basename $0` <lxr.conf>" >&2
}

[ $# -ne 1 ] && { usage; exit 1; }
[ ! -r "$1" ] && { echo "Cannot read the config file: $1" >&2; exit 1; }

awk '
    /range.*\qw/  {in_range=1;next}
    /)]/          {in_range=0;next}
    in_range==1   {print gensub(/^[ \t]*/,"",1)}

' "$1"
