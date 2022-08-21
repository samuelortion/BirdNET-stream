# All in One Docker Container for BirdNET-stream application

## Requirements

- docker

## Quick start

```bash
git clone https://github.com/UncleSamulus/BirdNET-stream.git
cd ./BirdNET-stream/docker/all
docker build -t "birdnet_all:latest" -f ./docker/all/Dockerfile .
```

If `docker` command does not work because of unsufficient permissions, you could add your user to `docker` group:

```bash
sudo usermod -aG docker $USER
```

Then logout, reconnect and try again.

Then, docker container should be run this way:

```bash
docker run -it birdnet_all --restart unless-stopped
```