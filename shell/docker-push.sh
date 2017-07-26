#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# Push our image to wherever it's defined to go by the name
docker push "$DOCKER_IMAGE"
