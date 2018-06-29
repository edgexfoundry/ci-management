#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# Strip -SNAPSHOT from pom if DOCKER_TAG is not set
if [[ -z "$DOCKER_TAG" ]]; then
  find . -name "*.xml" -print0 | xargs -0 sed -i 's/-SNAPSHOT//g'
fi

