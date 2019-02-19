#!/bin/bash
# Ensure we fail the job if any steps fail
set -ex -o pipefail

# Required Parameters

#   <NEXUS_URL>:      URL of Nexus server. Eg: https://nexus.edgexfoundry.org
#   <NEXUS_PATH>:     Path on nexus logs repo to place the logs. Eg:
#                     snapshots/branch/$BUILD_ID
#                     or
#                     release/branch
#   <NEXUS_REPO>:     Name of the nexus repo to use
#   <DOC_DIRECTORY>:  Absolute path of doc build step output directory.

pip install --user lftools

zip -r docs.zip ${DOC_DIRECTORY}
lftools deploy nexus-zip ${NEXUS_URL} ${NEXUS_REPO} ${NEXUS_PATH} docs.zip
