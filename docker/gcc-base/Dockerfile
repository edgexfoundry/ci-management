#
# Copyright (c) 2018
# Intel
#
# SPDX-License-Identifier: Apache-2.0
#
FROM alpine:3.7

LABEL license='SPDX-License-Identifier: Apache-2.0' \
      copyright='Copyright (c) 2018: Intel'

RUN echo http://nl.alpinelinux.org/alpine/v3.7/main > /etc/apk/repositories; \
    echo http://nl.alpinelinux.org/alpine/v3.7/community >> /etc/apk/repositories

RUN apk update && \
    apk add --update --no-cache build-base git gcc cmake make linux-headers yaml yaml-dev libmicrohttpd-dev libcurl curl-dev wget