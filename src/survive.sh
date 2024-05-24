#!/usr/bin/env bash

set -euo pipefail

PACKAGE_LIST_UPDATED=false

is_package_manager_available() {
    local package_manager="$1"
    command -v "$package_manager" &> /dev/null 
}

is_package_manager_apt() {
    is_package_manager_available "apt"
}

install_packages_with_apt() {
    local packages="$*"
    [[ "$PACKAGE_LIST_UPDATED" == false ]] && apt update && PACKAGE_LIST_UPDATED=true
    "$(command -v apt)" install "$packages" -y
}

install_survival_tools_process() {
    is_package_manager_apt \
        && install_packages_with_apt "procps" \
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
    -h                        Help
    -p                        Install process management tools

Example:
    ./$script_name
EOF
}

main() {
    local survival_enabled_all=true
    local survival_enabled_process=false
    while getopts ":hp" option; do 
        survival_enabled_all=false
        case "$option" in 
            h) usage && exit 0 ;;
            p) survival_enabled_process=true;;
            *) usage && exit 1 ;;
        esac
    done
    shift $(("$OPTIND" - 1))

    log_install_survival_tools "all" "$survival_enabled_all"

    log_install_survival_tools "process" "$survival_enabled_process"
    [[ "$survival_enabled_process" == true ]] && install_survival_tools_process
    
}

main "$@"