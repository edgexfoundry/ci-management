#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

virtualenv venv
source venv/bin/activate
pip install --upgrade setuptools pip
pip install docker-compose
if [[ "$NODE_NAME" == "cavium-arm64" ]]
then
  source bin/arm64_env.sh
else
  source bin/env.sh
fi
bash deploy-edgeX.sh
 