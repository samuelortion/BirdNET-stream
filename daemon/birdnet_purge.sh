#! /usr/bin/env bash
# Remove as much as possible as audio files that are not really helpful
#

set -e
# set -x

DEBUG=${DEBUG:-0}
DRY=${DRY:-0}
debug() {
    [[ $DEBUG -eq 1 ]] && echo "$@"
}

remove_selected() {
    local selected_audios
    selected_audios="$1"
    for audio in $selected_audios; do
        debug "Removing $audio"
        rm "$CHUNK_FOLDER/out/$audio"
    done
}

remove_audios_older_than() {
    local pivot_date=$1
    touch -t "$(date -d "$pivot_date" +"%Y%m%d%H%M")" /tmp/birdnet_purge.sh.pivot_date
    if [[ $DRY -eq 1 ]]; then
        find "$CHUNK_FOLDER/out/" -type f -name '*.wav' -not -newer /tmp/birdnet_purge.sh.pivot_date
    else
        find "$CHUNK_FOLDER/out/" -type f -name '*.wav' -not -newer /tmp/birdnet_purge.sh.pivot_date -delete
    fi
}

# Remove audios containing only excluded species
remove_audios_containing_only_excluded_species() {
    local excluded_species
    excluded_species=$1
    local audios
    audios=$(find "$CHUNK_FOLDER/out/" -type f -name '*.wav')
    audios=$(only_audios_containing_excluded_species "$audios" "$excluded_species")
    if [[ $DRY -eq 1 ]]; then
        echo "$audios"
    else
        remove_selected "$audios"
    fi
}

# Filter audio list, keep only those that contains only bird calls of selected exclude list
only_audios_containing_excluded_species() {
    local audios
    audios=$1
    local excluded_species
    excluded_species=$2
    local selected
    selected=""
    if [[ -z $excluded_specie ]]; then
        echo "No species to exclude"
        return 1
    fi
    for file in $audios; do
        if [[ $(contains_only_excluded_species "$file" "$excluded_species") -eq 1 ]]; then
            selected="$selected $file"
        fi
    done
}

# Check whether the audio file contains only excluded species
contains_only_excluded_species() {
    local audio
    audio=$1
    local excluded_species
    excluded_species=$2
    local flag
    flag=1
    IFS=$','
    local regex
    for species in $(get_contacted_species "$audio"); do
        regex="$species"
        if [[ $excluded_species =~ $regex ]]; then
            flag=0
            break
        fi
    done
    echo flag
}

# Get all scientific names of species detected by the model
get_contacted_species() {
    local audio
    audio=$1
    local model_output_path
    model_output_path="$CHUNK_FOLDER/out/$audio.d/model.out.csv"
    observations=$(tail -n +2 < "$model_output_path")
    IFS=$'\n'
    debug "Observations retrieved from $model_output_path"
    local species
    local contacted_species
    contacted_species=""
    for observation in $observations; do
        if [[ -z "$observation" ]]; then
            continue
        fi
        species=$(echo "$observation" | cut -d"," -f3)
        contacted_species="${contacted_species},${species}"
    done
    echo "$contacted_species"
}

main() {
    debug "Launching birdnet purge script"
    local config_path
    config_path="./config/birdnet.conf"
    if [[ ! -f $config_path ]]; then
        echo "Config file $config_path not found"
        exit 1
    fi
    source "$config_path"
    if [[ -z ${CHUNK_FOLDER} ]]; then
        echo "CHUNK_FOLDER is not set"
        exit 1
    else
        if [[ ! -d ${CHUNK_FOLDER}/out ]]; then
            echo "CHUNK_FOLDER does not exist: ${CHUNK_FOLDER}/out"
            echo "Cannot clean absent folder."
            exit 1
        fi
    fi
    today=$(date +"%Y-%m-%d")
    pivot_date=$(date -d "$today - $DAYS_TO_KEEP days" +"%Y-%m-%d")
    debug "Recordings older than $pivot_date will be removed"
    remove_audios_older_than "$pivot_date"
    if [[ -z ${EXCLUDED_SPECIES} ]]; then
        echo "No species to exclude"
        exit 1
    else
        if [[ -f ${EXCLUDED_SPECIES} ]]; then
            excluded_species=$(cat "${EXCLUDED_SPECIES}")
            remove_audios_containing_only_excluded_species "$excluded_species"
        else
            echo "Excluded species file ${EXCLUDED_SPECIES} not found"
            exit 1
        fi
    fi
}

main