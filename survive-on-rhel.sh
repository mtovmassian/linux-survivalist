#!/usr/bin/env bash

main() {
    docker run -it --rm \
        --mount type=bind,source="$(pwd)"/src,target=/opt/src \
        -w /opt/src \
        rockylinux:9.3-minimal \
        /bin/bash
}

main