# Use docker to run BirdNET-stream

There are two ways to run BirdNET-stream using docker: a "all in one" container, running all services on the same container, or using a splitted approach, running each service on a separate container.

## Prerequisites

- docker
- docker-compose (for splitted approach)
- git

## Using the all in one container (not working yet)

The all in one container is a container that runs all services on the same container.

You can follow the instructions in [./docker/all/README.md](./docker/all/README.md) to create this container.

## Using the splitted approach (recommended)

The splitted approach uses docker-compose and a docker container for each service.

This is the recommended approach to run BirdNET-stream while using docker.

Thirst of of all, you need to clone the repository.

```bash
mkdir ~/Documents/BirdNET-stream
cd ~/Documents/BirdNET-stream
git clone -b main https://github.com/UncleSamulus/BirdNET-stream.git .
```

Then, run docker-compose:

```bash
docker-compose up
```

## Building and running each of the containers 

### birdnet_recording container

Building:
```bash
docker build -f ./docker/recording/Dockerfile -t birdnet_recording:latest .
```
Running
```bash
docker run --rm --device /dev/snd birdnet_recording:latest
```

### birdnet_www container

Building:
```bash
docker build -f ./docker/www/Dockerfile -t birdnet_www:latest .
```

Running
```bash
docker run --rm birdnet_www:latest
```