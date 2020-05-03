#!/bin/bash
export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx build \
  --platform linux/arm/v7,linux/arm/v6,linux/arm64,linux/amd64 \
  --pull \
  -t subdavis/pihole-cloudsync . $@
