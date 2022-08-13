# !/bin/bash

# Extract data generated with BirdNET on record to get relevant informations and record data in sqlite

# Load config file
config_filepath="./config/analyzer.conf"
if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

# Verify needed prerequisites
if [[ -z ${CHUNK_FOLDER} ]]; then
    echo "CHUNK_FOLDER is not set"
    exit 1
else
    if [[ ! -d "${CHUNK_FOLDER}" ]]; then
        echo "CHUNK_FOLDER does not exist: ${CHUNK_FOLDER}"
        exit 1
    else
        if [[ ! -d "${CHUNK_FOLDER}/out" ]]; then
            echo "Output dir does not exist: ${CHUNK_FOLDER}/out"
            echo "Cannot mine data"
            exit 1
        fi
        fi
    fi
fi

function list_all_model_outputs()
{

}