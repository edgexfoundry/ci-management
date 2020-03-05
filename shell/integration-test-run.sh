#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

bin/run.sh -all postman-integration-test

if [ "${FOR_REDIS:=true}" = true ]; then
     sed -E -i "s/testsuite name=\"/testsuite name=\"redis_/" $(ls bin/testResult/*.xml)
else
     sed -E -i "s/testsuite name=\"/testsuite name=\"mongo_/" $(ls bin/testResult/*.xml)
fi
