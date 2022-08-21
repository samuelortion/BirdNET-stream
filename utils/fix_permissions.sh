#! /usr/bin/env bash
# Fix permissions on BirdNET-stream files when messed up
set -e

DEBUG=${DEBUG:-0}
debug() {
    [ $DEBUG -eq 1 ] && echo "$@"
}

config_filepath="./config/birdnet.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

GROUP=birdnet

sudo chown -R $USER:$GROUP $CHUNK_FOLDER
sudo chmod -R 775 $CHUNK_FOLDER