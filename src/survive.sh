#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAPPED=false
STDOUT_REDIRECT="/dev/stdout"

declare -A SURVIVAL_OPTIONS
SURVIVAL_OPTIONS[process]=false
SURVIVAL_OPTIONS[disk]=false

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

enable_all_survival_options_if_none() {
    for survival_option in "${!SURVIVAL_OPTIONS[@]}"; do
        [[ "${SURVIVAL_OPTIONS[$survival_option]}" == true ]] && return 0
    done
    for survival_option in "${!SURVIVAL_OPTIONS[@]}"; do
        SURVIVAL_OPTIONS["$survival_option"]=true
    done
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

    while getopts ":-:hqpd" option; do 
        case "$option" in 
            h) usage && exit 0 ;;
            q) STDOUT_REDIRECT="/dev/null";;
            p) SURVIVAL_OPTIONS[process]=true;;
            d) SURVIVAL_OPTIONS[disk]=true;;
            -)
                case "$OPTARG" in
                    help) usage && exit 0 ;;
                    quiet|silent) STDOUT_REDIRECT="/dev/null";;
                    process) SURVIVAL_OPTIONS[process]=true;;
                    disk) SURVIVAL_OPTIONS[disk]=true;;
                    *) usage && exit 1 ;;
                esac
                ;;
            *) usage && exit 1 ;;
        esac
    done
    shift $(( "$OPTIND" - 1))

    enable_all_survival_options_if_none

    log_install_survival_tools "process" "${SURVIVAL_OPTIONS[process]}"
    [[ "${SURVIVAL_OPTIONS[process]}" == true ]] && install_survival_tools_process
   
   log_install_survival_tools "disk" "${SURVIVAL_OPTIONS[disk]}"
    [[ "${SURVIVAL_OPTIONS[disk]}" == true ]] && install_survival_tools_disk
    
}

main "$@"