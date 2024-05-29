#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAPPED=false
STDOUT_REDIRECT="/dev/stdout"

declare -A SURVIVAL_OPTIONS
SURVIVAL_OPTIONS[process]=false
SURVIVAL_OPTIONS[disk]=false
SURVIVAL_OPTIONS[text]=false

apk_cli() { command -v apk; }
apt_cli() { command -v apt; }
dnf_cli() { command -v dnf || command -v microdnf; }

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
} > "$STDOUT_REDIRECT" 2>&1

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
} > "$STDOUT_REDIRECT" 2>&1

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

install_survival_tools_text() {
    install_with_apk less vim jq \
        || install_with_apt less vim jq \
        || install_with_dnf less vim jq
}


log_install_survival_tools() {
    local survival_option="$1"
    local survival_option_enabled="\e[1;34mdisabled\e[0m"
    is_enabled_survival_option "$survival_option" && survival_option_enabled="\e[1;32menabled\e[0m"
    
    printf "Survive by installing management tools for %-7s: %b\n" "$survival_option" "$survival_option_enabled"

}

enable_all_survival_options_if_none() {
    for survival_option in "${!SURVIVAL_OPTIONS[@]}"; do
        is_enabled_survival_option "$survival_option" && return 0
    done
    for survival_option in "${!SURVIVAL_OPTIONS[@]}"; do
        SURVIVAL_OPTIONS["$survival_option"]=true
    done
}

is_enabled_survival_option() {
    local survival_option="$1"
    [[ "${SURVIVAL_OPTIONS[$survival_option]}" == true ]]
}

usage() {
    script_name="$(basename "$0")"
    cat << EOF
Usage: ./$script_name [OPTIONS]

Survive in Linux/Docker environments by installing essential tools.

Options:
    -h, --help              Help
    -q, --quiet, --silent   Survive in silence without printing package manager logs
    -p, --process           Survive by installing management tools for process
    -d, --disk              Survive by installing management tools for disk
    -t, --text              Survive by installing management tools for text

Example:
    ./$script_name
EOF
}

main() {

    while getopts ":-:hqpdt" option; do 
        case "$option" in 
            h) usage && exit 0 ;;
            q) STDOUT_REDIRECT="/dev/null";;
            p) SURVIVAL_OPTIONS[process]=true;;
            d) SURVIVAL_OPTIONS[disk]=true;;
            t) SURVIVAL_OPTIONS[text]=true;;
            -)
                case "$OPTARG" in
                    help) usage && exit 0 ;;
                    quiet|silent) STDOUT_REDIRECT="/dev/null";;
                    process) SURVIVAL_OPTIONS[process]=true;;
                    disk) SURVIVAL_OPTIONS[disk]=true;;
                    text) SURVIVAL_OPTIONS[text]=true;;
                    *) usage && exit 1 ;;
                esac
                ;;
            *) usage && exit 1 ;;
        esac
    done
    shift $(( "$OPTIND" - 1))

    enable_all_survival_options_if_none

    log_install_survival_tools "process"
    is_enabled_survival_option "process" && install_survival_tools_process
   
    log_install_survival_tools "disk"
    is_enabled_survival_option "disk" && install_survival_tools_disk
    
    log_install_survival_tools "text"
    is_enabled_survival_option "text" && install_survival_tools_text
    
}

main "$@"