#! /usr/bin/env bash

# Load config file
config_filepath="./config/analyzer.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

# Remove all files from the temporary record directory
function clean_record_dir()
{
    rm -rf "$CHUNK_FOLDER/in/*.wav"
}

function remove_empty_records()
{
    find $CHUNK_FOLDER/in -maxdepth 1 -name '*wav' -type f -size 0 -delete
}

remove_empty_records