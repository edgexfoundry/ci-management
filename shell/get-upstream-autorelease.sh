#!/bin/bash
# Do not fail this job as this is a stopgap for now.
set +e

upstream_name=$(curl $BUILD_URL/consoleText | grep "Started by upstream project" | awk -F '"' '{print $2}')
upstream_number=$(curl $BUILD_URL/consoleText | grep "Started by upstream project" | awk -F '"' '{print $3}' | awk -F ' ' '{print$3}')
upstream_url="https://jenkins.edgexfoundry.org/job/$upstream_name/$upstream_number/consoleText"

AUTORELEASE=$(curl $upstream_url | grep "Completed uploading files to autorelease" | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')