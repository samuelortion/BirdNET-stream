#! /usr/bin/env bash

send() {
    message=$1
    if [ -z "$message" ]; then
        echo "No message to send"
        exit 1 
    fi
    apprise -vv -t "BirdNET-stream" -b "$message" \
    --config "./config/apprise.conf"
}

send $1