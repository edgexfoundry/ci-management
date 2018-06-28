#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail
snapcraft login --with $HOME/EdgeX

# Build snap and grab the generated snap name
SNAP_TO_PUSH=$(snapcraft | awk '/Snapped/ {print $2}')

# Push the generated snap and grab the revision number
REVISION=$(snapcraft push $SNAP_TO_PUSH | awk '/Revision/ {print $2}')

# Release the snap to channel
snapcraft release edgexfoundry $REVISION --channel=$SNAP_CHANNEL
