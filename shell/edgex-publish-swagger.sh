#!/bin/bash

set -e -o pipefail

# NOTE: APIKEY will need to be set locally from your environment or from Jenkins

echo "--> edgex-go-publish-swagger.sh"

# if no ARCH is set or ARCH is not arm
if [ -z "$ARCH" ] || [ "$ARCH" != "arm64" ] ; then
    API_VERSION=${API_VERSION:-2.0.0}
    API_FOLDER=${API_FOLDER:-v2}
    SWAGGER_DRY_RUN=${SWAGGER_DRY_RUN:-false}

    SCRIPTS_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

    . $SCRIPTS_ROOT/toSwaggerHub.sh

    OASVERSION='3.0.0'
    ISPRIVATE=true
    OWNER='EdgeXFoundry1'

    publishToSwagger "${APIKEY}" "${API_FOLDER}" "${API_VERSION}" "${OASVERSION}" "${ISPRIVATE}" "${OWNER}" "${SWAGGER_DRY_RUN}"
else
    echo "$ARCH not supported...skipping."
fi