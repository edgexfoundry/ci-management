#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

docker run --rm -v $PWD:$PWD:rw,z -w $PWD -v /var/run/docker.sock:/var/run/docker.sock --privileged \
-e SECURITY_SERVICE_NEEDED=$SECURITY_SERVICE_NEEDED --env-file $ENV_FILE \
-e docker_compose_test_tools=$docker_compose_test_tools \
--entrypoint /bin/sh $DOCKER_COMPOSE bin/run.sh -all postman-integration-test

sudo chown jenkins:jenkins bin/testResult
sudo chmod g+w bin/testResult

sed -E -i "s/testsuite name=\"/testsuite name=\"redis_/" $(ls bin/testResult/*.xml)
