#!/bin/bash -x

# Note that since this script gets included into a yaml string using jjb's
# include-raw-escape macro, we can't use any squiggly braces here, otherwise
# they will get duplicated in the resultant job definition.
# For some reason we also can't use include-raw macro because that macro will
# attempt to interpret anything contained in a macro as a jenkins key to
# expand which we also don't want.

# If we are running inside a jenkins instance then copy the login file and 
# figure out what kind of job type we are running as
if [ -n "$JENKINS_URL" ]; then
    # Since we are running from jenkins, use the workspace as the git root
    GIT_ROOT=$WORKSPACE
    if [ -f "$HOME/EdgeX" ]; then
       cp "$HOME/EdgeX" "$GIT_ROOT/edgex-snap-store-login"
    else
        echo "I seem to be running on Jenkins, but there's not a snap store login file..." 
    fi

    # Figure out what kind of job this is using $JOB_NAME and simplify that 
    # into $JOB_TYPE
    if [[ "$JOB_NAME" =~ .*-snap-.*-stage-snap.* ]]; then
        JOB_TYPE="stage"
    elif [[ "$JOB_NAME" =~ .*-snap-release-snap ]]; then
        JOB_TYPE="release"
    else
        JOB_TYPE="build"
    fi
else
    # We're not running in a jenkins container so assume the current working 
    # directory is the repo git dir that we want
    # TODO: maybe support providing the dir to use as the git root as an arg
    # or option to this script?
    GIT_ROOT=$PWD
fi

# Find the name of this snap from the snapcraft.yaml "name" key.
# Note that we assume that snapcraft.yaml is located in snap/snapcraft.yaml 
# but it is technically allowed to store it in other locations, we just don't
# support that here
# TODO: implement better handling of snapcraft.yaml file discovery
SNAP_NAME=$(grep -Po '^name: \K(.*)' snap/snapcraft.yaml)

# Save the entrypoint.sh script inside the build context we will send to docker.
# We have to do this because the dockerfile needs access to that file from its
# build context, so either we download the entrypoint script, or we include it
# into the filesystem build context. Downloading isn't great because then 
# there's additional linkages between this script and wherever we download from
# and it gets complicated to manage that.
# Note the file is saved at snap/entrypoint.sh
(
cat <<'EOF'
#!/bin/bash -e

# Required by the python click framework.
export LC_ALL=C.UTF-8
export SNAPCRAFT_SETUP_CORE=1

# This tells snapcraft to include a manifest file in the snap
# detailing which packages were used to build the snap.
export SNAPCRAFT_BUILD_INFO=1

# If snapcraft ever encounters any bugs, we should force it to 
# auto-report silently rather than attempt to ask for permission
# to send a report.
export SNAPCRAFT_ENABLE_SILENT_REPORT=1

case "$JOB_TYPE" in 
    "stage")
        # Stage jobs build the snap locally and release it
        pushd /build > /dev/null
        snapcraft clean
        snapcraft
        popd > /dev/null
        pushd /build > /dev/null
        snapcraft login --with /build/edgex-snap-store-login
        # Push the snap up to the store and release it on the specified
        # channel
        snapcraft push "$SNAP_NAME"*.snap --release "$SNAP_CHANNEL" 
        # Also force an update of the meta-data
        snapcraft push-metadata "$SNAP_NAME"*.snap --force
        popd > /dev/null
    ;;
    "release")
        # Release jobs will promote an already built snap revision
        # in the store to a channel.
        snapcraft login --with /build/edgex-snap-store-login
        snapcraft release "$SNAP_NAME" "$SNAP_REVISION" "$SNAP_CHANNEL"
    ;;
    *)
        # Do normal build and nothing else to verify the snap builds
        pushd /build > /dev/null
        snapcraft clean
        snapcraft
        popd > /dev/null
    ;;
esac

EOF
) > "$GIT_ROOT/snap/entrypoint.sh"

chmod +x "$GIT_ROOT/snap/entrypoint.sh"

# Build the container image, providing the relevant architecture we're on
# to determine which snap arch to download in the docker container.
case $(arch) in 
    x86_64)
        arch="amd64";;
    aarch64)
        arch="arm64";;
    arm*)
        arch="armhf";;
esac
docker build -t edgex-snap-builder:latest --build-arg ARCH="$arch" "$GIT_ROOT" -f- <<'EOF'
FROM ubuntu:18.04

# Allow specifying the architecture from the build arg command line
ARG ARCH

# The following snippet is essentially the same as the upstream dockerfile
# here: https://github.com/snapcore/snapcraft/blob/master/docker/stable.Dockerfile
# except we also specify the architecture to download so that this works
# on other architectures like arm64, etc.
# Basically, we send a command to the snap store for the info on the core +
# snapcraft snaps, extract the download link from the JSON result and then 
# download and extract the snaps into the docker container.
# We do this because we can't easily run snapd (and thus snaps) inside a 
# docker container without disabling important security protections enabled 
# for docker containers.
RUN apt-get update && \
    apt-get dist-upgrade --yes && \
    apt-get install --yes \
    curl sudo jq squashfs-tools && \
    for thesnap in core core18 snapcraft; do \
        dlUrl=$(curl -s -H 'X-Ubuntu-Series: 16' -H "X-Ubuntu-Architecture: $ARCH" "https://api.snapcraft.io/api/v1/snaps/details/$thesnap" | jq '.download_url' -r) && \
        dlSHA=$(curl -s -H 'X-Ubuntu-Series: 16' -H "X-Ubuntu-Architecture: $ARCH" "https://api.snapcraft.io/api/v1/snaps/details/$thesnap" | jq '.download_sha512' -r) && \
        curl -s -L $dlUrl --output $thesnap.snap && \
        echo "$dlSHA $thesnap.snap" > $thesnap.snap.sha512 && \
        sha512sum -c $thesnap.snap.sha512 && \
        mkdir -p /snap/$thesnap && \
        unsquashfs -n -d /snap/$thesnap/current $thesnap.snap && \
        rm $thesnap.snap.sha512 && \
        rm $thesnap.snap; \
    done && \
    apt remove --yes --purge curl jq squashfs-tools && \
    apt-get autoclean --yes && \
    apt-get clean --yes

# The upstream dockerfile just uses this file locally from the repo since it's
# in the same build context, but rather than copy that file here into the 
# build context before running, we can just download it from github directly
# While unlikely, it is possible that the file location could move in the 
# upstream git repo on the master branch, so for stability in our builds, just
# hard-code the git commit that most recently updated this file as the 
# revision to download from.
# Note: If this script ever breaks with the version of snapcraft we downloaded
# above, try updating this Dockerfile to do same as whatever the upstream
# docker image does
ADD https://raw.githubusercontent.com/snapcore/snapcraft/25043ab3667d24688b3d93dcac9f9a74f35dae9e/docker/bin/snapcraft-wrapper /snap/bin/snapcraft
RUN sed -i -e "s@\"amd64\"@$ARCH@" /snap/bin/snapcraft && chmod +x /snap/bin/snapcraft

# Snapcraft will be in /snap/bin, so we need to put that on the $PATH
ENV PATH=/snap/bin:$PATH

# Include all of the build context inside /build
COPY . /build

# Run the entrypoint.sh script to actually perform the build when the 
# container is run
WORKDIR /build
ENTRYPOINT [ "/build/snap/entrypoint.sh" ]
EOF

# Always delete the login file we copied to the git root so it doesn't persist
rm "$GIT_ROOT/edgex-snap-store-login"

# Finally, run the build with the environment variables 
docker run --rm \
    -e "JOB_TYPE=$JOB_TYPE" \
    -e "SNAP_REVISION=$SNAP_REVISION" \
    -e "SNAP_CHANNEL=$SNAP_CHANNEL" \
    -e "SNAP_NAME=$SNAP_NAME" \
    edgex-snap-builder:latest

# Note that we don't need to delete the docker images here, that's done for us
# by jenkins in the edgex-provide-docker-cleanup macro defined for all the 
# snap jobs
