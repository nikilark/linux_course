#!/usr/bin/bash

function print_help() {
        printf "%s COMMAND DICTIONARY ARGUMENTS...\n\tCOMMAND one of:\n\t\tstart\n\t\tlen\n" $0
        exit 0
}

function check_dictionary() {
        test -f $1 && test -s $1
}

function start() { # dictionary, start
        check_dictionary $1 && grep -E "^$2" $1
}

function len() { # dictionary, min, max
        if ! check_dictionary $1
                then
                        return 1
                fi
        if [ ! "$2" -le 0 ] || [ "$3" -le "$2" ] 
                then
                        echo "len : Invalid min or max"
                        return 2
                fi
        grep -E "^.{$2,$3}$" $1

}

if [ $# -eq 0 ]
then
        print_help
fi

while [ $# -gt 0 ]
do
        echo "Checking argument $1..."
        case $1 in
                start)
                        start $2 $3
                        shift
                        shift
                        ;;
                len)
                        len $2 $3 $4 ; for i in 1 2 3; do shift; done
                        ;;
                help|--help|-h)
                        print_help
                        ;;
                *)
                        echo "Unknown command $1"
                        print_help
                        ;;
        esac
shift
done
exit 0