#! /usr/bin/env bash
# Compress wav to flac and archive them as zip

# Requires: tar, gzip, ffmpeg

set -e

DEBUG=${DEBUG:-0}
debug() {
    [[ $DEBUG -eq 1 ]] && echo "$@"
}
error() {
    echo 1>&2 "$@"
}

audio_compress() {
    local filepath
    filepath="$1"
    if [[ "$DRY" -eq 1 ]]; then
        debug "Would compress $filepath to flac"
        return 0
    else
        debug "Compressing $filepath"
        ffmpeg -i "$filepath" -acodec flac -compression_level 10 "${filepath%.wav}.flac"
    fi
}

all_audio_compress() {
    local dir
    dir="$1"
    debug "Compressing all .wav audio in $dir"
    for filepath in "$dir"/*.wav; do
        if [[ "$DRY" -eq 1 ]]; then
            debug "Would convert $filepath to flac and remove it"
        else
            audio_compress "$filepath"
            debug "Removing $filepath"
            rm "$filepath"
        fi
    done
}

record_datetime() {
    source_wav=$1
    source_base=$(basename "$source_wav" ".wav")
    record_date=$(echo "$source_base" | cut -d"_" -f2)
    record_time=$(echo "$source_base" | cut -d"_" -f3)
    YYYY=$(echo "$record_date" | cut -c 1-4)
    MM=$(echo "$record_date" | cut -c 5-6)
    DD=$(echo "$record_date" | cut -c 7-8)
    HH=$(echo "$record_time" | cut -c 1-2)
    MI=$(echo "$record_time" | cut -c 3-4)
    SS=$(echo "$record_time" | cut -c 5-6)
    SSS="000"
    date="$YYYY-$MM-$DD $HH:$MI:$SS.$SSS"
    echo "$date"
}

source_wav() {
    model_output_dir="$1"
    wav=$(basename "$model_output_dir" | rev | cut --complement -d"." -f1 | rev)
    echo "$wav"
}

birdnet_archive_older_than() {
    local days
    days="$1"
    local date
    date=$(date +"%Y-%m-%d")
    local date_pivot
    date_pivot=$(date -d "$date + $days days" +"%Y-%m-%d")
    move_records_to_archive "$date_pivot"
    zip_archives
}

move_records_to_archive() {
    local date
    date="$1"
    local archives_dir
    archives_dir="$2"
    archive_path="${ARCHIVE_DIR}/$date"
    debug "Moving records from $CHUNK_FOLDER/out to $archives_path"
    for filepath in $(find "$CHUNK_FOLDER/out/" -name '*.wav.d'); do
        wav=$(source_wav "$filepath")
        dir=$(dirname "$filepath")
        record_datetime=$(record_datetime "$wav")
        if [[ "$record_datetime" == "$date" ]]; then
            debug "Moving $filepath to $archive_path"
            if [[ ! -d "$archive_path" ]]; then
                mkdir -p "$archive_path"
            fi
            mv "$filepath" "$archive_path"
            debug "Moving model output directory to archive"
            mv "$dir" "$archive_path/"
            debug "Moving wav to archive"
            mv "$CHUNK_FOLDER/out/$wav" "$archive_path/"
        fi
    done
}

zip_archives() {
    debug "Zipping archives in ${ARCHIVE_DIR}"
    for archive_path in $(find "${ARCHIVE_DIR}" -type d); do
        archive_name="birdnet_$(basename "$archive_path" | tr '-' '').tar.gz"
        if [[ "$DRY" -eq 1 ]]; then
            debug "Would zip $archive_path to $archive_name"
        else
            debug "Zipping $archive_path to $archive_name"
            tar -czf "$archive_name" -C "$archive_path" .
            debug "Removing temporary archive folder in ${ARCHIVE_DIR}"
            rm -rf "$archive_path"
        fi
    done
}

main() {
    config_filepath="./config/birdnet.conf"
    [ -f "$config_filepath" ] || {
        error "Config file not found: $config_filepath"
        exit 1
    }
    source "$config_filepath"
    if [[ -z "CHUNK_FOLDER" ]]; then
        error "CHUNK_FOLDER not set in config file"
        exit 1
    fi
    if [[ -z "ARCHIVE_FOLDER" ]]; then
        error "ARCHIVE_FOLDER not set in config file"
        exit 1
    fi
    debug "Launch birdnet archive script from $CHUNK_FOLDER to $ARCHIVE_FOLDER"
    birdnet_archive_older_than $DAYS_TO_KEEP
}
