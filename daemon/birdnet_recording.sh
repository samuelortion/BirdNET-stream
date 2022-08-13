#! /usr/bin/env bash

record_chunk() {
    DEVICE=$1
    DURATION=$2
    ffmpeg -f pulse -i ${DEVICE} -t ${DURATION} -vn -acodec pcm_s16le -ac 1 -ar 48000 file:${CHUNK_FOLDER}/in/birdnet_$(date "+%Y%m%d_%H%M%S").wav
}

config_filepath="./config/analyzer.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

[ -z $RECORDING_DURATION ] && RECORDING_DURATION=15

if [[ -z $AUDIO_DEVICE ]]; then
    echo "AUDIO_DEVICE is not set"
    exit 1
fi

check_folder() {
    if [[ ! -d "${CHUNK_FOLDER}" ]]; then
        echo "CHUNK_FOLDER does not exist: ${CHUNK_FOLDER}"
        echo "Creating recording dir"
        mkdir -p "${CHUNK_FOLDER}/in"
    fi
}

check_folder

while true; do
    record_chunk $AUDIO_DEVICE $RECORDING_DURATION
done
