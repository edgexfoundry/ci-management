#!/bin/bash
# Do not allow script to fail if no pom.xml exists
set +e

# Strip -SNAPSHOT from pom if DOCKER_TAG is not set
if [[ -z "$DOCKER_TAG" ]]; then
  find . -name "*.xml" -print0 | xargs -0 sed -i 's/-SNAPSHOT//g'
fi
exit 0
