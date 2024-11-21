#!/usr/bin/bash

function help_message() {
    printf "USAGE : %s [OPTIONS] WHAT WHERE\n\tOPTIONS:\n\t\t-h -- display this message\n\t\t-v -- invert match\n\t\t-m number -- max matches\n" $0
    exit 1
}

if [[ $# -lt 2 ]]; then
    help_message $@
fi

function match_word() {
    if [[ $1 =~ .*$2.* ]]; then
        return 0
    else
        return 1
    fi
}

function reverse_match_word() {
    if match_word $1 $2; then
        return 1
    else
        return 0
    fi
}

invert=""
max_match=""
for arg in $@
do
    case $arg in
        -h|--help)
            help_message $@
        ;;
        -v|--invert)
            invert="yes"
            shift
        ;;
        -m|--max)
            max_match=$2
            shift 2
        ;;
    esac
done

WHAT=$1
WHERE=$2

current_matches=0

for word in $(cat $WHERE); do
    matched_word=""
    if [ -z $invert ]; then
        match_word $word $WHAT && matched_word=$word
    else
        reverse_match_word $word $WHAT && matched_word=$word
    fi
    
    if [ -n "$matched_word" ]; then
        echo $word
        current_matches=$((current_matches+1))
        
        if [ -n $max_match ] && [ $current_matches -ge $max_match ]; then
            break
        fi
    fi
done


if [[ $current_matches -gt 0 ]]; then
    exit 0
else
    exit 2
fi
