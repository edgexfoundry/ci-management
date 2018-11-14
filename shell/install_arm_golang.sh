#!/bin/bash

# This is a temporary workaround for security-secret-store, which advertently depended on golang 1.10.X
# before the project officially moved.  Install dynamically at runtime for now.
sudo mkdir /opt/go1105
sudo curl -L https://dl.google.com/go/go1.10.5.linux-arm64.tar.gz -o go1.10.5.linux-arm64.tar.gz
sudo tar -C /opt/go1105 -xzf go1.10.5.linux-arm64.tar.gz
GOROOT=/opt/go1105/go
PATH=$PATH:$GOROOT/bin
go version
