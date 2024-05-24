#!/usr/bin/env bash

main() {
    docker run -it --rm \
        --mount type=bind,source="$(pwd)"/src,target=/opt/src \
        -w /opt/src \
        alpine:3.20 \
        /bin/sh -c "apk add bash && /bin/bash"
}

main