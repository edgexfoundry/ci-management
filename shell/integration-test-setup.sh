#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

if [[ "$NODE_NAME" == "cavium-arm64" ]]
then
  source bin/arm64_env.sh
else
  sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  source bin/env.sh
fi
bash deploy-edgeX.sh

