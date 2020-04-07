#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

if [[ `uname -m` != "x86_64" ]]
then
  sed -e 's/export //g; 1d;/\$/d' bin/arm64_env.sh > arm64.env
  export ENV_FILE=arm64.env
  export DOCKER_COMPOSE="nexus3.edgexfoundry.org:10003/edgex-devops/edgex-compose-arm64:latest"
else
  sed -e 's/export //g; 1d;/\$/d' bin/env.sh > x86_64.env
  export ENV_FILE=x86_64.env
  export DOCKER_COMPOSE="nexus3.edgexfoundry.org:10003/edgex-devops/edgex-compose:latest"
fi

export docker_compose_test_tools=$PWD/docker-compose-test-tools.yml

docker run --rm -v $PWD:$PWD:rw,z -w $PWD -v /var/run/docker.sock:/var/run/docker.sock --privileged \
-e SECURITY_SERVICE_NEEDED=$SECURITY_SERVICE_NEEDED -e DATABASE=$DATABASE --env-file $ENV_FILE \
--entrypoint /bin/sh $DOCKER_COMPOSE deploy-edgeX.sh

