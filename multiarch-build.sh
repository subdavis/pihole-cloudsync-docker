#!/bin/bash
export DOCKER_CLI_EXPERIMENTAL=enabled

# ARMEL (v6) 32 bit
export TAG="master-armel"
envsubst '${TAG}' < Dockerfile.template > Dockerfile.armel
docker buildx build --platform linux/arm/v6 --pull -t subdavis/pihole-cloudsync:armel -f Dockerfile.armel . --load

# ARMHF (v7) 32 bit
export TAG="master-armhf"
envsubst '${TAG}' < Dockerfile.template > Dockerfile.armhf
docker buildx build --platform linux/arm/v7 --pull -t subdavis/pihole-cloudsync:armhf -f Dockerfile.armhf . --load

# ARM64 (v8) 64 bit
export TAG="master-arm64"
envsubst '${TAG}' < Dockerfile.template > Dockerfile.arm64
docker buildx build --platform linux/arm64 --pull -t subdavis/pihole-cloudsync:arm64 -f Dockerfile.arm64 . --load

# X86 64
export TAG="master-amd64"
envsubst '${TAG}' < Dockerfile.template > Dockerfile.amd64
docker buildx build --platform linux/amd64 --pull -t subdavis/pihole-cloudsync:amd64 -f Dockerfile.amd64 . --load
# Also make this the "latest" tag
docker tag subdavis/pihole-cloudsync:amd64 subdavis/pihole-cloudsync:latest

if [ "$1" == 'push' ]; then
  docker push subdavis/pihole-cloudsync:latest
  docker push subdavis/pihole-cloudsync:amd64
  docker push subdavis/pihole-cloudsync:arm64
  docker push subdavis/pihole-cloudsync:armhf
  docker push .template:armel
fi

docker images | grep subdavis/pihole-cloudsync
