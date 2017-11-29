#!/bin/bash
# Ensure we fail the job if any steps fail
# Do not set -u as DOCKER_ARGS may be unbound
set -e -o pipefail

if [[ -z "$DOCKER_TAG" ]]; then
    DOCKER_TAG=$( xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" pom.xml )
fi

# Switch to the directory where the Dockerfile is
cd "$DOCKER_ROOT"

# DOCKERREGISTRY is purposely not using an '_' so as to not conflict with the
# Jenkins global env var of the DOCKER_REGISTRY which the docker-login step uses
IMAGE_NAME="$DOCKERREGISTRY/$DOCKER_NAME:$DOCKER_TAG"

# Build the docker image

# Allow word splitting
# shellcheck disable=SC2086
docker build $DOCKER_ARGS . -t $IMAGE_NAME | tee "$WORKSPACE/docker_build_log.txt"

# Write DOCKER_IMAGE information to a file so it can be injected into the
# environment for following steps
echo "DOCKER_IMAGE=$IMAGE_NAME" >> "$WORKSPACE/env_inject.txt"

