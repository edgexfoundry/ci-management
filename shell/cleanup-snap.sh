#!/bin/bash
set +e  # DO NOT cause build failure if any of the rm calls fail.
rm -f "$HOME/EdgeX"
# DO NOT fail build if any of the above lines fail.
exit 0