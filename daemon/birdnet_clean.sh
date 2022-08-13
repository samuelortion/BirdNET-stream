#! /usr/bin/env bash
##
## Clean up var folder from useless files
##

config_filepath="./config/analyzer.conf"

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
    rm -rf $(junk)
}

# Check if string contains string
mem() {
    string=$2
    substring=$1
    if [[ "$string" == *"$substring"* ]]; then
        true
    else
        false
    fi
}

# Get list of junk files
junk() {
    # Get all empty files from treatement folder
    find "${CHUNK_FOLDER}/out" -type f -name '*.wav' -size 0
    for file in $junk; do
        folder=$(wav2dir_name "$file")
        if [[ -d $folder ]]; then
            junk="$junk $folder"
        fi
    done
    # Get all empty files from record folder
    junk=$(find "${CHUNK_FOLDER}/in" -type f -name '*.wav' -exec basename {} \; ! -size 0)
    # Get all empty treatment directories
    junk="$junk $(find ${CHUNK_FOLDER}/out -type d -empty)"
    # Get all empty record directories
    treatement_folder=$(find "${CHUNK_FOLDER}/out/*" -type d ! -empty)
    if [[ ! -z ${treatement_folder} ]]; then
        for folder in $treatement_folder; do
            echo $folder
            if ! $(mem $folder $junk) && $(no_bird_in_model_output $folder); then
                junk="$junk $folder"
            fi
        done
    fi
    echo "$junk"
}

no_bird_in_model_output() {
    folder=$1
    output="${folder}/model.out.csv"
    lines=$(wc -l < "$output")
    if [[ $lines -eq 1 ]]; then
        echo "true"
    else
        echo "false"
    fi
}

main() {
    clean
}

main