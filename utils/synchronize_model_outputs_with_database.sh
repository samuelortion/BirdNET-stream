#! /usr/bin/env bash
# Extract observations from a model output folder
#
set -e
# set -x

DEBUG=${DEBUG:-1}
debug() {
    [[ $DEBUG -eq 1 ]] && echo "$@"
}
if [[ -f ./config/birdnet.conf ]]; then
    source ./config/birdnet.conf
else 
    debug "./config/birdnet.conf does not exist"
    exit 1
fi
if [[ ! -d ${CHUNK_FOLDER} ]]; then
    debug "CHUNK_FOLDER ${CHUNK_FOLDER} does not exist"
    exit 1
fi

model_outputs() {
    ls ${CHUNK_FOLDER}/out/*/model.out.csv
}

main() {
    # # Remove all junk observations
    # ./daemon/birdnet_clean.sh
    # Get model outputs
    for model_output in $(model_outputs); do
        ./daemon/birdnet_output_to_sql.sh "$model_output"
    done
}

main