# Installation Guide for BirdNET-stream

## Requirements

- git
- ffmpeg
- python3

## Install process

### Install python requirements

```bash
sudo apt-get update
sudo apt-get install python3-dev python3-pip
sudo pip3 install --upgrade pip
```

### Install ffmpeg

```bash
sudo apt-get install ffmpeg
```

### Clone BirdNET-stream repository

```bash
git clone https://forge.chapril.org/UncleSamulus/BirdNET-stream.git

### Setup python virtualenv and packages

```bash
python3 -m venv .venv/birdnet-stream
source .venv/birdnet-stream

pip install -r requirements.txt
```
