#! /usr/bin/env bash

DEBUG=${DEBUG:-1}

export PULSE_RUNTIME_PATH="/run/user/$(id -u)/pulse/"

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

check_folder() {
    if [[ ! -d "${CHUNK_FOLDER}" ]]; then
        debug "CHUNK_FOLDER does not exist: ${CHUNK_FOLDER}"
        debug "Creating recording dir"
        mkdir -p "${CHUNK_FOLDER}/in"
    fi
}

record_loop() {
    DEVICE=$1
    DURATION=$2
    debug "New recording loop."
    while true; do
        record_device $DEVICE $DURATION
    done
}

FFMPEG_OPTIONS="-nostdin -hide_banner -loglevel error -nostats -vn -acodec pcm_s16le -ac 1 -ar 48000 "

record_stream() {
    local STREAM=$1
    local DURATION=$2
    local debug "Recording from $STREAM for $DURATION seconds"
    ffmpeg $FFMPEG_OPTIONS -f -i ${DEVICE} -t ${DURATION} file:${CHUNK_FOLDER}/in/birdnet_$(date "+%Y%m%d_%H%M%S").wav
}

record_device() {
    DEVICE=$1
    DURATION=$2
    debug "Recording from $DEVICE for $DURATION seconds"
    ffmpeg $FFMPEG_OPTIONS -f pulse -i ${DEVICE} -t ${DURATION} -af "volume=$RECORDING_AMPLIFY" file:${CHUNK_FOLDER}/in/birdnet_$(date "+%Y%m%d_%H%M%S").wav
}

config_filepath="./config/birdnet.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

check_folder

[ -z $RECORDING_DURATION ] && RECORDING_DURATION=15

if [[ $AUDIO_RECORDING = "true" ]]; then
    debug "Recording with on board device"
    if [[ -z $AUDIO_DEVICE ]]; then
        echo "AUDIO_DEVICE is not set"
        exit 1
    fi
    record_loop $AUDIO_DEVICE $RECORDING_DURATION
fi

if [[ $AUDIO_STATIONS = "true" ]]; then
    for station in $(ls ./config/stations/*.conf); do
        source $station
        record_stream $STATION_URL $RECORDING_DURATION
    done
fi
