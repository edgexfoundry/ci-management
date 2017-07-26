#!/bin/bash
# Ensure we fail the job if any steps fail
# Do not set -u as DOCKER_ARGS may be unbound
set -e -o pipefail

# Switch to the directory where the Dockerfile is
cd "$DOCKER_ROOT"

# Build the docker image

# Allow word splitting
# shellcheck disable=SC2086
docker build $DOCKER_ARGS . | tee "$WORKSPACE/docker_build_log.txt"
DOCKER_IMAGE=$(grep -Po 'Successfully built \K[^ ]+' \
    "$WORKSPACE/docker_build_log.txt")

# DOCKERREGISTRY is purposely not using an '_' so as to not conflict with the
# Jenkins global env var of the DOCKER_REGISTRY which the docker-login step uses
IMAGE_NAME="$DOCKERREGISTRY/$DOCKER_NAME:$DOCKER_TAG"

docker tag "$DOCKER_IMAGE" "$IMAGE_NAME"

# Write DOCKER_IMAGE information to a file so it can be injected into the
# environment for following steps
echo "DOCKER_IMAGE=$IMAGE_NAME" >> "$WORKSPACE/env_inject.txt"

