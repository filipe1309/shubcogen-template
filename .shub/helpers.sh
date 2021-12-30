#!/bin/bash

# DevOntheRun Helpers Script

function parse_json() {
    echo $1 | \
    sed -e 's/[{}]/''/g' | \
    sed -e 's/", "/'\",\"'/g' | \
    sed -e 's/" ,"/'\",\"'/g' | \
    sed -e 's/" , "/'\",\"'/g' | \
    sed -e 's/","/'\"---SEPERATOR---\"'/g' | \
    awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}" | \
    sed -e "s/\"$2\"://" | \
    tr -d "\n\t" | \
    sed -e 's/\\"/"/g' | \
    sed -e 's/\\\\/\\/g' | \
    sed -e 's/^[ \t]*//g' | \
    sed -e 's/^"//'  -e 's/"$//' | \
    sed -e 's/"//' | \
    sed -e 's/ $//'
}

format_json() {
    echo $1 | \
    grep -Eo '"[^"]*" *(: *([0-9]*|"[^"]*")[^{}\["]*|,)?|[^"\]\[\}\{]*|\{|\},?|\[|\],?|[0-9 ]*,?' | \
    awk '{if ($0 ~ /^[}\]]/ ) offset-=4; printf "%*c%s\n", offset, " ", $0; if ($0 ~ /^[{\[]/) offset+=4}'
}

function confirm() {
    read -r -p "${1:-Are you sure? [Y/n]} " response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        echo "Ok"
    else
        exit 0;
    fi
}


readArguments() {
    echo "👉 use -h to show help"
    echo ""
    while getopts "a,h,m:" opt; do
        case $opt in
            a) all="y"
            ;;
            m) message=$(echo "$*" | sed -e 's/-a//' -e 's/-m//' -e 's/-h//'| sed -e 's/^[[:space:]]*//')
            ;;
            h) echo "Usage: $0 [-a] [-m message] [-h]"
                echo "  -a: Accept all"
                echo "  -m: Tag message"
                echo "  -h: Help"
                exit 0
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac

        case $OPTARG in
            -a) echo "Option $opt needs a valid argument"
            exit 1
            ;;
        esac
    done
}
