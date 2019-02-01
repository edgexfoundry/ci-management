#!/bin/bash
set -ex -o pipefail

echo "--> device_sdk_c_build.sh"

userId=`id -u`
groupId=`id -g`

mkdir $WORKSPACE/release

DOCKER_BUILD_CONTAINER=${DOCKER_NAME}-builder-${BUILD_ID}

echo "Starting build container and generating tar.gz"
# --privileged is required because for some reason when docker bind mounts the
# on the workspace on the Jenkins build server, it is Read-Only
docker run --rm -e UID=$userId -e GID=$groupId --privileged -v $WORKSPACE/release:/edgex-c-sdk/build/release ${DOCKER_IMAGE}

echo "Contents of release directory:"
ls -al $WORKSPACE/release