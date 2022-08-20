#! /usr/bin/env bash

set -e

DEBUG=${DEBUG:-1}
debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

config_filepath="./config/analyzer.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi


GROUP=birdnet

sudo chown -R $USER:$GROUP $CHUNK_FOLDER
sudo chmod -R 775 $CHUNK_FOLDER