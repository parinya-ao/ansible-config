#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - BOOTSTRAP SCRIPT                        #
#         Minimal bootstrapper for Fedora Workstation provisioning             #
#                                                                               #
# Architecture: Domain-Driven Design (DDD)                                     #
#   - Domain Layer: Business logic for system validation                       #
#   - Application Layer: Use cases for installation workflows                   #
#   - Infrastructure Layer: External service integration                        #
#   - Shared Kernel: Common utilities and messaging                            #
#################################################################################

set -euo pipefail

#################################################################################
#                                CONSTANTS                                       #
#################################################################################

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VENV_DIR="${PROGDIR}/.ansible-venv"
readonly ANSIBLE_VERSION="${ANSIBLE_VERSION:-2.18}"  # Pinned for stability

# Retry configuration
readonly MAX_RETRIES="${MAX_RETRIES:-3}"
readonly RETRY_DELAY="${RETRY_DELAY:-5}"

# Timeout configuration (seconds)
readonly DNF_TIMEOUT="${DNF_TIMEOUT:-300}"
readonly GALAXY_TIMEOUT="${GALAXY_TIMEOUT:-180}"

#################################################################################
#                              LIBRARY LOADING                                #
#################################################################################

_load_library() {
    local lib_name="$1"
    local lib_path="${LIB_DIR}/${lib_name}"

    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    else
        echo "Error: Library ${lib_name} not found at ${LIB_DIR}" >&2
        return 1
    fi
}

# Shared Kernel: UI/Output libraries
_load_library "colors.sh"              || exit 1
_load_library "print_hr.sh"             || exit 1
_load_library "print_header.sh"         || exit 1
_load_library "print_step.sh"           || exit 1
_load_library "print_info.sh"           || exit 1
_load_library "print_success.sh"        || exit 1
_load_library "print_warn.sh"           || exit 1
_load_library "print_error.sh"          || exit 1
_load_library "print_list.sh"           || exit 1

# Shared Kernel: Utility libraries
_load_library "utils/command_utils.sh"     || exit 1
_load_library "utils/usage.sh"              || exit 1
_load_library "utils/parsing.sh"            || exit 1
_load_library "utils/cleanup.sh"            || exit 1
_load_library "utils/checks.sh"             || exit 1
_load_library "utils/version_display.sh"    || exit 1
_load_library "utils/messages.sh"           || exit 1

# Domain Layer: Business logic
_load_library "domain/system_checks.sh"     || exit 1
_load_library "domain/dnf_checks.sh"         || exit 1

# Infrastructure Layer: External services
_load_library "infrastructure/dnf_installer.sh"  || exit 1

# Application Layer: Use cases/workflows
_load_library "application/package_installer.sh"     || exit 1
_load_library "application/venv_setup.sh"             || exit 1
_load_library "application/collections_installer.sh" || exit 1
_load_library "application/playbook_runner.sh"       || exit 1

#################################################################################
#                               MAIN ENTRY                                      #
#################################################################################

main() {
    setup_venv
    install_collections
    run_playbook "$@"
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
