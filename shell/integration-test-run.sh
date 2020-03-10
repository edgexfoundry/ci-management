#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

cd bin; bash ./run.sh -all postman-integration-test

if [ "${DATABASE:=redis}" = redis ]; then
     sed -E -i "s/testsuite name=\"/testsuite name=\"redis_/" $(ls testResult/*.xml)
else
     sed -E -i "s/testsuite name=\"/testsuite name=\"mongo_/" $(ls testResult/*.xml)
fi
