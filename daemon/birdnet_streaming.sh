#! /usr/bin/env bash

DEBUG=${DEBUG:-1}

export PULSE_RUNTIME_PATH="/run/user/$(id -u)/pulse/"

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

stream() {
    DEVICE=$1
    debug "Launching audio stream from $DEVICE at icecast://source:secret@$ICECAST_HOST:$ICECAST_PORT/$ICECAST_MOUNT"
    ffmpeg  -nostdin -hide_banner -loglevel error -nostats \
        -f pulse -i $DEVICE -vn -acodec libmp3lame -ac 1 -ar 48000 -content_type 'audio/mpeg' \
        -f mp3 "icecast://source:${ICECAST_PASSWORD}@${ICECAST_HOST}:${ICECAST_PORT}/${ICECAST_MOUNT}" -listen 1
}

config_filepath="./config/birdnet.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

if [[ -z $AUDIO_DEVICE ]]; then
    echo "AUDIO_DEVICE is not set"
    exit 1
fi

if [[ -z $ICECAST_HOST ]]; then
    echo "ICECAST_HOST is not set"
    exit 1
fi
if [[ -z $ICECAST_PORT ]]; then
    echo "ICECAST_PORT is not set"
    exit 1
fi
if [[ -z $ICECAST_MOUNT ]]; then
    echo "ICECAST_MOUNT is not set"
    exit 1
fi
if [[ -z $ICECAST_PASSWORD ]]; then
    echo "ICECAST_PASSWORD is not set"
    exit 1
fi
stream $AUDIO_DEVICE
