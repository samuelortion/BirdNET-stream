#! /usr/bin/env bash
set -X
set -e

DEBUG=${DEBUG:-0}

# Standard Installation Script for BirdNET-stream for Debian Based Linux distros

REQUIREMENTS="git ffmpeg python3-pip python3-dev"
REPOSITORY="https://github.com/UncleSamulus/BirdNET-stream.git"
PYTHON_VENV=".venv/birdnet-stream"

# Update system
update() {
    sudo apt-get update
    sudo apt-get upgrade
}

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

install_requirements() {
    if 
    requirements=$1
    # Install requirements
    missing_requirements=""
    for requirement in $requirements; do
        if ! dpkg -s $requirement >/dev/null 2>&1; then
            missing_requirements="$missing_requirements $requirement"
        fi
    done
    if [ -n "$missing_requirements" ]; then
        debug "Installing missing requirements: $missing_requirements"
        sudo apt-get install $missing_requirements
    fi
}

# Install BirdNET-stream
install_birdnetstream() {
    # Clone BirdNET-stream
    debug "Cloning BirdNET-stream from $REPOSITORY"
    git clone --recurse-submodules $REPOSITORY
    # Install BirdNET-stream
    cd BirdNET-stream
    debug "Creating python3 virtual environment '$PYTHON_VENV'"
    python3 -m venv $PYTHON_VENV
    debug "Activating $PYTHON_VENV"
    source .venv/birdnet-stream/bin/activate
    debug "Installing python packages"
    pip install -U pip
    pip install -r requirements.txt
}

# Install systemd services
install_birdnetstream_services() {
    debug "Setting up BirdNET stream systemd services"
    sudo ln -s $PWD/BirdNET-stream/daemon/systemd/birdnet_recording.service /etc/systemd/system/birdnet_recording.service
    sudo ln -s $PWD/BirdNET-stream/daemon/systemd/birdnet_analyzis.service /etc/systemd/system/birdnet_analyzis.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now birdnet_recording.service birdnet_analyzis.service
}

main() {
    install_requirements $REQUIREMENTS
    install_birdnetstream
    install_birdnetstream_services
}

main