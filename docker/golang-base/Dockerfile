#
# Copyright (c) 2018
# Intel
#
# SPDX-License-Identifier: Apache-2.0
#
FROM golang:1.11.2-alpine3.7

LABEL license='SPDX-License-Identifier: Apache-2.0' \
      copyright='Copyright (c) 2018: Intel'

RUN echo http://nl.alpinelinux.org/alpine/v3.7/main > /etc/apk/repositories; \
    echo http://nl.alpinelinux.org/alpine/v3.7/community >> /etc/apk/repositories

RUN apk update && \
    apk add --no-cache linux-headers make gcc musl-dev git glide

#Optional dependencies. These are useful for generating reports for tools like SonarQube and Jenkins

# Installing gometalinter
# Usage example: gometalinter.v2 --checkstyle --vendor --disable gotype --deadline=120s --config=/linter-settings.json ./...
RUN  go get -u gopkg.in/alecthomas/gometalinter.v2 &&  gometalinter.v2 --install
COPY docker/golang-base/linter-settings.json /

# Installing gocov to output code coverage xml files. Useful for SonarQube code coverage
# Usage Example: gocov test ./... | gocov-xml
RUN go get github.com/axw/gocov/... && \
    go get github.com/AlekSi/gocov-xml

# Install JUnit style plugin for exporting to report.xml files. Useful for Jenkins JUnit Plugin
# Usage example: go test ./... -v 2>&1 | go-junit-report
RUN go get -u github.com/jstemmer/go-junit-report

