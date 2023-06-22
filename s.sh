#!/usr/bin/bash
declare -r DEBUG=1

log() {
    if [ $DEBUG = 1 ]
    then
        echo "$1" >&2;
    fi
}

echo "Hello, World"
log "Hello, Error"
