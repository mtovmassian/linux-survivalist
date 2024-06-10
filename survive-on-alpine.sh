#!/usr/bin/env bash

SCRIPT_DIR="$(readlink -f "$0" | xargs dirname)"
readonly SCRIPT_DIR

main() {
    docker run -it --rm \
        --mount type=bind,source="${SCRIPT_DIR}"/src,target=/opt/src \
        -w /opt/src \
        alpine:3.20 \
        /bin/sh -c "apk add bash && /bin/bash"
}

main