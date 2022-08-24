<h1 align="center">BirdNET-stream</h1>

<p align="center">Realtime BirdNET powered soundscape analysis for bird song identification.</p>

<p align="center">
    <img src="./media/logo.svg" alt="BirdNET-stream logo image IA generated" style="width: 500px">
</p>

## Introduction

BirdNET-stream records sound 24/7 on any Linux computer with a microphone and analyze it using BirdNET algorithm by [**@kahst**](https://github.com/kahst).

Bird contacts are stored in a database and are made accessible in a webapp.

## Features

- 24/7 recording and [BirdNET-Analyzer](https://github.com/kahst/BirdNET-Analyzer) analysis of sound
- Live audio streaming and live spectrogram visualization from web browser
- Bird contacts saved into a SQL database
- Web Interface for system monitoring, data analysis and visualization

## Requirements

BirdNET-stream aims to be able to run on any 64-bit Linux computer.
It has been tested on Fedora and Debian.

It should work on a Raspberry Pi (or other Single Board Computer) with a USB microphone or Sound Card (not tested yet).

## Installation

> **Warning** BirdNET-stream is in early development, and may not work properly...

<!-- On debian based system, you can install BirdNET-stream with the following command:

```bash
curl -sL https://raw.githubusercontent.com/UncleSamulus/BirdNET-stream/main/install.sh | bash
``` -->

On debian based systems (tested on Debian Bullseye), the following command should allow you to install the base components without too much trouble:

```bash
# Change to your installation directory here, /home/$USER/Documents/BirdNET-stream for instance, or /opt/birdnet-stream, or whatever
cd /path/to/installation/directory
# Download installation script 
curl -0 https://raw.githubusercontent.com/UncleSamulus/BirdNET-stream/main/install.sh
# Run installation script:
chmod +x ./install.sh
./install.sh
```

I recommend to add `DEBUG=1` before this command to see the installation steps:
```bash
DEBUG=1 ./install.sh
```

To install from a specific git branch, add `BRANCH=<branch>` before the command, for instance:

```bash
BRANCH=dev DEBUG=1 ./install.sh
```

For finer control, or to adapt to your system, you can follow the instructions in the [INSTALL.md](./INSTALL.md) file (it may unfortunatly not be accurate for your system).


## Usage

- BirdNET-stream web application can be accessed on any web browser at [https://birdnet.home](https://birdnet.home), from your local network, or at any other hostname you set in nginx configuration, if your public IP is accessible from the internet.

- See the species detected

## Acknoledgments

- [BirdNET](https://birdnet.cornell.edu) on which this project relies
- [BirdNET-Pi](https://birdnetpi.com) the great inspiration of this project

## License

BirdNET-stream is licensed under the GNU General Public License v3.0, see [./LICENSE](./LICENSE) for more details.
