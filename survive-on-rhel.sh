#!/usr/bin/env bash

SCRIPT_DIR="$(readlink -f "$0" | xargs dirname)"
readonly SCRIPT_DIR

main() {
    docker run -it --rm \
        --mount type=bind,source="${SCRIPT_DIR}"/src,target=/opt/src \
        -w /opt/src \
        rockylinux:9.3-minimal \
        /bin/bash
}

main