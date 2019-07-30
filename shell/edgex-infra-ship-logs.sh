#!/bin/bash
echo "---> edgex-infra-ship-logs.sh"

ARCH=$(uname -m)
env | grep -v PATH > .env
docker container run \
  --privileged \
  --rm \
  --env-file=.env \
  -u 0:0 \
  -v $WORKSPACE:$WORKSPACE \
  -v ${WORKSPACE}@tmp:${WORKSPACE}@tmp \
  -v /home/jenkins:/home/jenkins \
  -e SERVER_ID=logs \
  nexus3.edgexfoundry.org:10003/edgex-lftools-log-publisher:${ARCH} \
  sh -c "sh global-jjb/shell/create-netrc.sh && \
         sh global-jjb/shell/logs-deploy.sh && \
         sh global-jjb/shell/logs-clear-credentials.sh"
exit 0