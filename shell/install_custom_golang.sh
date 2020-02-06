#!/bin/bash
echo "--> install_custom_golang.sh"

GO_VERSION=${GO_VERSION:-1.11.5}
GOARCH=${GOARCH:-amd64}

# This is a temporary workaround for Go based services, which will depended on golang 1.11.X
# Install dynamically at runtime for now.
sudo mkdir /opt/go-custom
sudo curl -L https://dl.google.com/go/go${GO_VERSION}.linux-${GOARCH}.tar.gz -o go${GO_VERSION}.linux-${GOARCH}.tar.gz
sudo tar -C /opt/go-custom -xzf go${GO_VERSION}.linux-${GOARCH}.tar.gz
sudo chmod -R 777 /opt/go-custom/go
GOROOT=/opt/go-custom/go
PATH=$PATH:$GOROOT/bin

go version