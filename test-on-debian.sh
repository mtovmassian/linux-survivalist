#!/usr/bin/env bash

main() {
    docker run -it --rm \
        --mount type=bind,source="$(pwd)"/src,target=/opt/src \
        -w /opt/src \
        debian:bookworm-slim \
        /bin/bash
}

main