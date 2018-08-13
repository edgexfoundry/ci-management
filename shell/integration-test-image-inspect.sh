#!/bin/bash
# Do not fail on this script
set +e

while IFS= read -a line; do
    image_array+=( "$line" )
    done < <( docker images --format "{{.Repository}}:{{.Tag}}" )

for image in "${image_array[@]}"
do
    image=$(echo "$image" | xargs)
    echo "Checking git_sha Label in image $image...."
    docker inspect $image | grep git_sha
done
