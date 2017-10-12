#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# Strip -SNAPSHOT from pom
find . -name "*.xml" -print0 | xargs -0 sed -i 's/-SNAPSHOT//g'
