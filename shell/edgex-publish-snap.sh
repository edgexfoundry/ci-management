#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail
snapcraft login --with $HOME/EdgeX

# Build the snap
snapcraft clean
snapcraft

# Push the generated snap and grab the revision number
REVISION=$(snapcraft push edgexfoundry*.snap | awk '/Revision/ {print $2}')

# Release the snap to channel
snapcraft release edgexfoundry $REVISION $SNAP_CHANNEL
