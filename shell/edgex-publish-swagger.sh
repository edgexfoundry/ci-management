#!/bin/bash

set -e -o pipefail

# NOTE: APIKEY will need to be set locally from your environment or from Jenkins

echo "--> edgex-go-publish-swagger.sh"

API_VERSION=${API_VERSION:-2.0.0}
API_FOLDER=${API_FOLDER:-v2}

SCRIPTS_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

. $SCRIPTS_ROOT/toSwaggerHub.sh

OASVERSION='3.0.0'
ISPRIVATE=true
OWNER='EdgeXFoundry1'

publishToSwagger "${APIKEY}" "${API_FOLDER}" "${API_VERSION}" "${OASVERSION}" "${ISPRIVATE}" "${OWNER}"