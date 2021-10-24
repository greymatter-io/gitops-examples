#!/bin/bash
set -e
dir="./1.7/" # must have trailing slash
cue_export () {
    local type=$1
    cue export $dir -e $type | jq '[to_entries[] | values | .value]'
}

validargs="domains|clusters|listeners|proxies|sharedrules|routes"

usage () {
    echo "provide exactly one argument, one of: [${validargs}]"
}

if [[ $# == 0 ]]; then
    usage
    exit 1
fi
case $1 in
    domains|clusters|listeners|proxies|sharedrules|routes)
        cue_export $1
        ;;
    *)
        echo "invalid argument \"$1\""
        usage
        exit 1
        ;;
esac

