#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

cd bin; bash ./run.sh -all postman-integration-test

