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

On debian based system, you can install BirdNET-stream with the following command:

```bash
curl -sL https://raw.githubusercontent.com/UncleSamulus/BirdNET-stream/main/install.sh | bash
```

For finer control, or to adapt to your system, you can follow the instructions in the [INSTALL.md](./INSTALL.md) file.

## Usage

- BirdNET-stream web application can be accessed on any web browser at [https://birdnet.home](https://birdnet.home), from your local network, or at any other hostname you set in nginx configuration, if your public IP is accessible from the internet.

- See the species detected 

## Acknoledgments

- [BirdNET](https://birdnet.cornell.edu) on which this project relies
- [BirdNET-Pi](https://birdnetpi.com) the great inspiration of this project

## License

BirdNET-stream is licensed under the GNU General Public License v3.0, see [./LICENSE](./LICENSE) for more details.