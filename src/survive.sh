#!/usr/bin/env bash

set -euo pipefail

APT_UPDATED=false

is_package_manager_available() { command -v "$1" &> /dev/null; }
is_package_manager_apk() { is_package_manager_available "apk" ;}
is_package_manager_apt() { is_package_manager_available "apt" ;}
is_package_manager_dnf() { 
    is_package_manager_available "dnf" || is_package_manager_available "microdnf"
}

install_with_apk() {
    local packages="$*"
    apk add $packages
}

install_with_apt() {
    local packages="$*"
    [[ "$APT_UPDATED" == false ]] && apt update && APT_UPDATED=true
    apt install $packages -y
}

install_with_dnf() {
    local packages="$*"
    local dnf_cli; dnf_cli="$(command -v dnf || command -v microdnf)"
    "$dnf_cli" install $packages -y
}

install_survival_tools_process() {
    is_package_manager_apk \
        && install_with_apk procps lsof \
        && return

    is_package_manager_apt \
        && install_with_apt procps lsof \
        && return

    is_package_manager_dnf \
        && install_with_dnf procps lsof \
        && return
}

log_install_survival_tools() {
    local survival_kind="$1"
    local survival_enabled="$2"
    local survival_enabled_text="\e[1;32m$survival_enabled\e[0m"
    [[ "$survival_enabled" == false ]] && survival_enabled_text="\e[1;34m$survival_enabled\e[0m"
    
    printf "Installing survival tools for %s: %b\n" "$survival_kind" "$survival_enabled_text"
}

usage() {
    script_name="$(basename "$0")"
    cat << EOF
Usage: ./$script_name [OPTIONS]

Options:
    -h, --help              Help
    -p, --process           Survive by installing process management tools

Example:
    ./$script_name
EOF
}

main() {
    local survival_enabled_all=true
    local survival_enabled_process=false
    while getopts ":-:hp" option; do 
        survival_enabled_all=false
        case "$option" in 
            h) usage && exit 0 ;;
            p) survival_enabled_process=true;;
            -)
                case "$OPTARG" in
                    help) usage && exit 0 ;;
                    process) survival_enabled_process=true;;
                    *) usage && exit 1 ;;
                esac
                ;;
            *) usage && exit 1 ;;
        esac
    done
    shift $(( "$OPTIND" - 1))

    log_install_survival_tools "all" "$survival_enabled_all"

    log_install_survival_tools "process" "$survival_enabled_process"
    [[ "$survival_enabled_process" == true ]] && install_survival_tools_process
    
}

main "$@"