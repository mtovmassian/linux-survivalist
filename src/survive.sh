#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAPPED=false
STDOUT_REDIRECT="/dev/stdout"

apk_cli() { command -v apk; }
apt_cli() { command -v apt; }
dnf_cli() { command -v dnf || command -v microdnf; }

is_package_manager_available() { command -v "$1" &> /dev/null; }

bootstrap_apk() {
    apk add coreutils
    BOOTSTRAPPED=true
}

bootstrap_apt() {
    apt update
    apt install coreutils -y
    BOOTSTRAPPED=true
}

bootstrap_dnf() {
    "$(dnf_cli)" install coreutils-single -y
    BOOTSTRAPPED=true
}

install_with_apk() {
    [[ -z "$(apk_cli)" ]] && return 1
    [[ "$BOOTSTRAPPED" == false ]] && bootstrap_apk
    local packages="$*"
    "$(apk_cli)" add $packages
}

install_with_apt() {
    [[ -z "$(apt_cli)" ]] && return 1
    [[ "$BOOTSTRAPPED" == false ]] && bootstrap_apt
    local packages="$*"
    "$(apt_cli)" install $packages -y
} > "$STDOUT_REDIRECT" 2>&1

install_with_dnf() {
    [[ -z "$(dnf_cli)" ]] && return 1
    [[ "$BOOTSTRAPPED" == false ]] && bootstrap_dnf
    local packages="$*"
    "$(dnf_cli)" install $packages -y
}

install_survival_tools_process() {
    install_with_apk procps lsof \
        || install_with_apt procps lsof \
        || install_with_dnf procps lsof
}

install_survival_tools_disk() {
    install_with_apk ncdu \
        || install_with_apt ncdu \
        || { install_with_dnf epel-release && install_with_dnf ncdu; }
}

log_install_survival_tools() {
    local survival_kind="$1"
    local survival_enabled="$2"
    local survival_enabled_text="\e[1;32m$survival_enabled\e[0m"
    [[ "$survival_enabled" == false ]] && survival_enabled_text="\e[1;34m$survival_enabled\e[0m"
    
    printf "Survive by installing %s management tools: %b\n" "$survival_kind" "$survival_enabled_text"
}

usage() {
    script_name="$(basename "$0")"
    cat << EOF
Usage: ./$script_name [OPTIONS]

Survive in Linux/Docker environments by installing essential tools.

Options:
    -h, --help              Help
    -q, --quiet, --silent   Survive in silence without printing package manager logs
    -p, --process           Survive by installing process management tools
    -d, --disk              Survive by installing disk management tools

Example:
    ./$script_name
EOF
}

main() {
    local is_enabled_survive_all=true
    local is_enabled_survive_process=false
    local is_enabled_survive_disk=false

    while getopts ":-:hqpd" option; do 
        is_enabled_survive_all=false
        case "$option" in 
            h) usage && exit 0 ;;
            q) STDOUT_REDIRECT="/dev/null";;
            p) is_enabled_survive_process=true;;
            d) is_enabled_survive_disk=true;;
            -)
                case "$OPTARG" in
                    help) usage && exit 0 ;;
                    quiet|silent) STDOUT_REDIRECT="/dev/null";;
                    process) is_enabled_survive_process=true;;
                    disk) is_enabled_survive_disk=true;;
                    *) usage && exit 1 ;;
                esac
                ;;
            *) usage && exit 1 ;;
        esac
    done
    shift $(( "$OPTIND" - 1))

    [[ "$is_enabled_survive_all" == true ]] \
        && is_enabled_survive_process=true \
        && is_enabled_survive_disk=true

    log_install_survival_tools "process" "$is_enabled_survive_process"
    [[ "$is_enabled_survive_process" == true ]] && install_survival_tools_process
    
    log_install_survival_tools "disk" "$is_enabled_survive_disk"
    [[ "$is_enabled_survive_disk" == true ]] && install_survival_tools_disk
    
}

main "$@"