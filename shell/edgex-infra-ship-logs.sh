#!/bin/bash
echo "---> edgex-infra-ship-logs.sh"

# determine location of sar standard activity daily file
if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
    SAR_FILE='/var/log/sysstat'
else
    SAR_FILE='/var/log/sa'
fi

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
  -v ${SAR_FILE}:/var/log/sa \
  -e SERVER_ID=logs \
  nexus3.edgexfoundry.org:10003/edgex-lftools-log-publisher:${ARCH} \
  sh -c "sh global-jjb/shell/create-netrc.sh && \
         sh global-jjb/shell/logs-deploy.sh && \
         sh global-jjb/shell/logs-clear-credentials.sh"
exit 0