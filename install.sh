#! /usr/bin/env bash
# set -x
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
    # Check if repo is not already installed
    workdir=$(pwd)
    if [ -d "$workdir/BirdNET-stream" ]; then
        debug "BirdNET-stream is already installed"
    else
        # Clone BirdNET-stream
        debug "Cloning BirdNET-stream from $REPOSITORY"
        git clone --recurse-submodules $REPOSITORY
        # Install BirdNET-stream
    fi
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
    cd BirdNET-stream
    DIR=$(pwd)
    GROUP=$USER
    echo $DIR
    debug "Setting up BirdNET stream systemd services"
    services="birdnet_recording.service birdnet_analyzis.service"
    for service in $services; do
        sudo cp daemon/systemd/templates/$service /etc/systemd/system/
        variables="DIR USER GROUP"
        for variable in $variables; do
            sudo sed -i "s|\$$variable|${!variable}|g" /etc/systemd/system/$service
        done
    done
    sudo systemctl daemon-reload
    sudo systemctl enable --now $services
}

install_web_interface() {
    debug "Setting up web interface"
    install_requirements "nginx php php-fpm composer nodejs npm"
    cd BirdNET-stream
    cd www
    debug "Creating nginx configuration"
    cp nginx.conf /etc/nginx/sites-available/birdnet-stream.conf
    sudo ln -s /etc/nginx/sites-available/birdnet-stream.conf /etc/nginx/sites-enabled/birdnet-stream.conf
    sudo systemctl enable --now nginx
    sudo systemctl restart nginx
    debug "Retrieving composer dependencies"
    composer install
    debug "Installing nodejs dependencies"
    sudo npm install -g yarn
    yarn build
    debug "Building assets"
    debug "Web interface is available"
}

main() {
    # update
    install_requirements $REQUIREMENTS
    install_birdnetstream
    install_birdnetstream_services
}

main
