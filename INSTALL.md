# Installation Guide for BirdNET-stream

This guide allow you to install BirdNET-stream step by step on your debian based system.

For a one-liner installation, you can use the following command:

```bash
curl -sL https://raw.githubusercontent.com/UncleSamulus/BirdNET-stream/main/install.sh | bash
```

For debug purposes, you can use the following command, it will log the installation steps to the console:

```bash
DEBUG=1 ./install.sh
```

If you need to use a specific branch (e.g. dev), you can use the following command:

```bash
BRANCH=dev ./install.sh
```

## Requirements

- git
- ffmpeg
- python3
- sqlite3

## Install process

### Install python requirements

```bash
sudo apt-get update
sudo apt-get install python3-dev python3-pip python3-venv
sudo pip3 install --upgrade pip
```

### Install ffmpeg

```bash
sudo apt-get install ffmpeg
```

### Clone BirdNET-stream repository

```bash
git clone --recurse-submodules https://github.com/UncleSamulus/BirdNET-stream.git
```

### Setup python virtualenv and packages

```bash
python3 -m venv .venv/birdnet-stream
source .venv/birdnet-stream

pip install -r requirements.txt
```

### Setup systemd services

```bash
# Copy and Adapt templates
services="birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer birdnet_miner.service"
read -r -a services_array <<<"$services"
for service in ${services_array[@]}; do
    sudo cp daemon/systemd/templates/$service /etc/systemd/system/
    variables="DIR USER GROUP"
    for variable in $variables; do
        sudo sed -i "s|<$variable>|${!variable}|g" /etc/systemd/system/$service
    done
done
# Enable services
sudo systemctl daemon-reload
sudo systemctl enable --now birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer
```

#### Check if services are working

```bash
# Sercices and timers status
sudo systemctl status birdnet_\*
```

```bash
# BirdNET-stream logs
sudo journalctl -feu birdnet_\*
```

#### Enable `loginctl-linger` for the user that runs the servuces

Running:
```bash
loginctl enable-linger
```
This allows to use `/run/user/1000/pulse` to record audio using PulseAudio in birdnet_recording.sh.

## Setup BirdNET-stream symfony webapp

### Install php 8.1

```bash
# Remove previously installed php version
sudo apt remove --purge php*
# Install required packages for php
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
# Get php package from sury repo
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
sudo wget -qO - https://packages.sury.org/php/apt.gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-php-8.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/debian-php-8.gpg
sudo apt update && sudo apt upgrade -y
sudo apt install php8.1
# Install and enable php-fpm
sudo apt install php8.1-fpm
sudo systemctl enable php8.1-fpm
# Install php packages
sudo apt-get install php8.1-{sqlite3,curl,intl}
```

### Install composer

```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"\nphp -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"\nphp composer-setup.php\nphp -r "unlink('composer-setup.php');"
sudo mv /composer.phar /usr/local/bin/composer
```

### Install webapp packages

```bash
cd www
composer install
```

### Install nodejs and npm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

```bash
nvm install 16
nvm use 16
```

```bash
sudo dnf install npm
```

```bash
sudo npm install -g yarn
```

```bash
yarn build
```

## Setup audio streaming with icecast and ffmpeg for live spectrogram

Install icecast:

```bash
sudo apt-get install icecast2
```

Modify icecast password:

```xml
[...]
<authentication>
    <!-- Sources log in with username 'source' -->
    <source-password>secret</source-password>
    <!-- Relays log in with username 'relay' -->
	<relay-password>secret</relay-password>
    <!-- Admin logs in with the username given below -->
    <admin-user>birdnet</admin-user>
    <admin-password>secret</admin-password>
</authentication>
[...]
```

Launch and enable icecast:

```bash
sudo systemctl enable --now icecast2
```

Adapt `config/birdnet.conf` to this configuration:

```conf
ICECAST_USER=source
ICECAST_PASSWORD=secret # change this to the password you set above
ICECAST_PORT=8000
ICECAST_HOST=localhost
ICECAST_MOUNT=stream
```

Launch and enable audio streamer daemon:

```bash
sudo systemctl enable --now birdnet_streaming.service
```

Add a reverse proxy to nginx to allow https

```nginx
server {
    [...]

    location /stream {
        proxy_pass http://localhost:8000/birdnet;
    }

    [...]
}
```

## Setup https certificates with dehydrated (only for public instances)

```bash
sudo apt-get install dehydrated
````

Edit `/etc/dehydrated/domains.txt` and add your domain name.

```bash
sudo vim /etc/dehydrated/domains.txt
```

Add acme-challenges alias to your nginx config:

```bash
server {
    [...]

    location /.well-known/acme-challenge {
        alias /var/www/html/.well-known/acme-challenge;
        allow all;
    }
}
```

Create acme-challenge directory:

```bash
sudo mkdir -p /var/www/html/.well-known/acme-challenge
```

Adapt `/etc/dehydrated/config`, by adding this folder to the `WELLKNOWN` path:

```bash
WELLKNOWN = "/var/www/html/.well-known/acme-challenge"
```

Register to certificate issuer and accept conditions and terms:

```bash
dehydrated --register --accept-terms
```

Generate certificates:

```bash
dehydrated -c
```

Add dehydrated cron

```bash
sudo crontab -e
```

```bash
00 00 01 * * dehydrated -c
```

(This updates the certicates every first day of the month, feel free to adapt to your needs.)

## Setup ttyd to stream audio to webapp

Change to a dedicated folder, build and install ttyd:

```bash
cd /opt
sudo wget wget https://github.com/tsl0922/ttyd/releases/download/1.7.1/ttyd.x86_64 # Change to your architecture and get last version
sudo mv ttyd.x86_64 ttyd
sudo chmod +x ttyd
```

Set up birdnet_ttyd systemd service to start as a daemon:

```bash
# Copy service template
sudo cp ./daemon/systemd/templates/birdnet_ttyd.service /etc/systemd/system/birdnet_ttyd.service
# Edit template and adapt placeholders
sudo vim /etc/systemd/system/birdnet_ttyd.service
# Enable and start ttyd service
sudo systemctl daemon-reload
sudo systemctl enable --now birdnet_ttyd.service
```

Then go to [https://birdnet.lan/ttyd](https://birdnet.lan/ttyd) and start streaming logs.