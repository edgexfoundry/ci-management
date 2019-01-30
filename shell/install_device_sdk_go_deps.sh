#!/bin/bash
echo "--> install_device_sdk_go_deps.sh"

GO_VERSION=${GO_VERSION:-1.11.2}
GOARCH=${GOARCH:-amd64}

# This is a temporary workaround for device-sdk-go, which will depended on golang 1.11.X
# Install dynamically at runtime for now.
sudo mkdir /opt/go${GO_VERSION}
sudo curl -L https://dl.google.com/go/go${GO_VERSION}.linux-${GOARCH}.tar.gz -o go${GO_VERSION}.linux-${GOARCH}.tar.gz
sudo tar -C /opt/go${GO_VERSION} -xzf go${GO_VERSION}.linux-${GOARCH}.tar.gz
GOROOT=/opt/go${GO_VERSION}/go
PATH=$PATH:$GOROOT/bin

go version