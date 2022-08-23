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

First of of all, you need to clone the repository.

```bash
mkdir ~/Documents/BirdNET-stream
cd ~/Documents/BirdNET-stream
git clone -b main https://github.com/UncleSamulus/BirdNET-stream.git .
```

Then, run docker-compose:

```bash
# Build image (first time only)
docker compose build
# Run
docker compose up # add `-d`, to run in background
# Stop
docker compose down
```

For a one liner:
```bash
docker compose up --build
```
