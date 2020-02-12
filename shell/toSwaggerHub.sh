#!/bin/bash

echo "--> toSwaggerHub.sh"

publishToSwagger() {
    apiKey=$1
    apiFolder=$2
    apiVersion=$3
    oasVersion=$4
    isPrivate=$5
    owner=$6
    dryRun=${7:-false}

    apiPath="$WORKSPACE/api/openapi/"${apiFolder}

    echo "[toSwaggerHub] Publishing the API Docs [${apiVersion}] to Swagger"

    if [ -d "$apiPath" ]; then
        for file in "${apiPath}"/*.yaml; do
            apiName=$(basename "${file}" | cut -d "." -f 1)
            apiContent=$(cat "${apiPath}/${apiName}".yaml)

            echo "[toSwaggerHub] Publishing API Name [$apiName]"

            if [ "$dryRun" == "false" ]; then
                curl -X POST "https://api.swaggerhub.com/apis/${owner}/${apiName}?isPrivate=${isPrivate}&version=${apiVersion}&oas=${oasVersion}&force=true" \
                    -H "accept:application/json" \
                    -H "Authorization:${apiKey}" \
                    -H "Content-Type:application/yaml" \
                    -d "${apiContent}"
            else
                echo "[toSwaggerHub] Dry Run enabled...Simulating upload"
                echo "curl -X POST https://api.swaggerhub.com/apis/${owner}/${apiName}?isPrivate=${isPrivate}&version=${apiVersion}&oas=${oasVersion}&force=true"
            fi

        done
    else
        echo "Could not find API Folder [${apiPath}]. Please make sure the API version exists..."
        exit 1
    fi
}
