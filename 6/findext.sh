#!/usr/bin/bash

action=$1

ext=$2

not=""

if [ "$action" = "" -o "$ext" = "" ]; then
    echo "USAGE : findext ACTION [--not] <ext>"
    echo "ACTION one of:"
    echo "     print      -- print files with(out) <ext>"
    echo "     remove     -- remove files with(out) <ext>"
    echo "     duplicates -- print duplicate files with(out) <ext>"
    exit 1
fi

if [ "$ext" = "--not" -o "$ext" = "-n" ]; then
    ext=$3
    if [ -z "$ext" ]; then
        echo "ERROR : <ext> is empty" >&2
        exit 4
    fi
    not="!"
fi

# find -name "*.test" -type f -exec rm {} \;
# find -type f ! -name "*.test" -exec basename {} \; | sort | uniq -d
# find -type f -name "*.test" -mmin 60 | xargs ls -t

# grep -Ei '^[...]+$' /usr/share/dict/words

case "$action" in
    print|p)
        find . -type f $not -name "*.$ext"
        exit 0
    ;;
    remove|r)
        find . -type f $not -name "*.$ext" -exec rm {} +
        exit 0
    ;;
    duplicates|d)
        find . -type f $not -name "*.$ext" -exec basename {} \; | sort | uniq -d
        exit 0
    ;;
    *)
        echo "ERROR : unknown ACTION \"$1\"" >&2
        exit 2
    ;;
esac