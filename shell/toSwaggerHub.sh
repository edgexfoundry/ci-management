#!/bin/bash

echo "--> toSwaggerHub.sh"

publishToSwagger() {
    apiKey=$1
    apiFolder=$2
    apiVersion=$3
    oasVersion=$4
    isPrivate=$5
    owner=$6
    apiPath="$WORKSPACE/api/openapi/"${apiFolder}

    echo "[toSwaggerHub] Publishing the API Docs [${apiVersion}] to Swagger"

    if [ -d "$apiPath" ]; then
        for file in "${apiPath}"/*.yaml; do
            apiName=$(basename "${file}" | cut -d "." -f 1)
            apiContent=$(cat "${apiPath}/${apiName}".yaml)

            echo "[toSwaggerHub] Publishing API Name [$apiName]"

            echo curl -X POST "https://api.swaggerhub.com/apis/${owner}/${apiName}?isPrivate=${isPrivate}&version=${apiVersion}&oas=${oasVersion}&force=true" \
                -H "accept:application/json" \
                -H "Authorization:${apiKey}" \
                -H "Content-Type:application/yaml" \
                -d "${apiContent}"
        done
    else
        echo "Could not API Folder [${apiPath}]. Please make sure the API version exists..."
        exit 1
    fi
}
