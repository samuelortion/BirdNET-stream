#! /usr/bin/env bash
##
## Clean up var folder from useless files (e.g empty wav, audio with no bird, etc)
##

set -e
# set -x

DEBUG=${DEBUG:-1}
debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "$1"
    fi
}

config_filepath="./config/birdnet.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

wav2dir_name() {
    wav_path=$1
    dir_name=$(basename "$wav_path" .wav)
    echo "$dir_name"
}

# Clean out folder from empty audio
clean() {
    for item in $(junk); do
        debug "Removing: $item"
        rm -rf "$CHUNK_FOLDER/out/$item"
    done
    empty_audios=$(find "$CHUNK_FOLDER/in" -type f -size 0)
    for item in $empty_audios; do
        rm -rf "$item"
    done
}

dryclean() {
    debug "Dry run mode"
    debug "Script will remove the following files:"
    for item in $(junk); do
        debug "$item"
    done
    empty_audios=$(find "$CHUNK_FOLDER/in" -type f -size 0)
    for item in $empty_audios; do
        echo "$item"
    done
}

# Get list of junk files
junk() {
    # Get all empty files from treatement folder
    junk=$(find "${CHUNK_FOLDER}/out" -type f -name '*.wav' -size 0)
    for file in $junk; do
        folder=$(wav2dir_name "$file")
        if [[ -d $folder ]]; then
            junk="$junk $folder"
        fi
    done
    # Get all empty treatment directories
    junk="$junk $(find ${CHUNK_FOLDER}/out/* -type d -empty)"
    # Get all no birdcontact directories
    treatement_folders=$(find ${CHUNK_FOLDER}/out/* -type d ! -empty)
    for folder in $treatement_folders; do
        folder_basename=$(basename "$folder")
        if [[ $(no_bird_in_model_output $folder_basename) = "true" ]]; then
            # Add model output file to junk list
            junk="$junk $folder_basename/model.out.csv"
            junk="$junk $folder_basename"
        fi
    done
    echo "$junk"
}

no_bird_in_model_output() {
    folder=$1
    output="$CHUNK_FOLDER/out/$folder/model.out.csv"
    if [[ -f $output ]]; then
        lines=$(wc -l <"$output")
    else
        lines=0
    fi
    if [[ $lines -eq 1 ]]; then
        echo "true"
    else
        echo "false"
    fi
}

if [[ $1 = "dry" ]]; then
    dryclean
else
    clean
fi
