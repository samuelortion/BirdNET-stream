#! /usr/bin/env bash
# Standard uninstallation script for BirdNET-stream installed on Debian Based Linux distros
set -e
# set -x 
DEBUG=${DEBUG:-0}
debug() {
    [[ $DEBUG -eq 1 ]] && echo "$@"
}

if [[ -f ./config/birdnet.conf ]]; then
    source ./config/birdnet.conf
fi

WORKDIR=${WORKDIR:-$(pwd)/BirdNET-stream}

# Remove systemd services
uninstall_birdnet_services() {
    debug "Removing systemd services"
    services=(birdnet_recording.service
            birdnet_streaming.service
            birdnet_miner.service
            birdnet_miner.timer
            birdnet_plotter.service
            birdnet_plotter.timer)
    for service in "$services"; do
        debug "Stopping $service"
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
        sudo rm -f "/etc/systemd/system/$service"
        sudo systemctl daemon-reload
    done
    debug "Done removing systemd services"
}

uninstall_webapp() {
    debug "Removing webapp"
    debug "Removing nginx server configuration"
    sudo unlink /etc/nginx/sites-enabled/birdnet-stream.conf
    sudo systemctl restart nginx
}

main() {
    echo "WARNING: This will remove all BirdNET-stream related files and services. \
    Note that it may forget some special configuration."
    uninstall_webapp
    uninstall_birdnet_services
}

main