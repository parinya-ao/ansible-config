#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - INITIALIZATION SCRIPT                  #
#         Production-grade bootstrap script for Fedora Workstation             #
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

readonly PROGNAME="$(basename "${0}")"
readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="${PROGDIR}/command/lib"
readonly PLAYBOOK="${PROGDIR}/playbook.yaml"
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
#                               MAIN ENTRY                                     #
#################################################################################

main() {
    # Set up traps for cleanup and error handling
    trap cleanup EXIT
    trap 'error_handler ${LINENO}' ERR

    # Parse arguments first (before accessing variables that depend on args)
    parse_args "$@"

    # Pre-flight checks
    if [[ "$SKIP_CHECK" != "true" ]]; then
        if ! preflight_check; then
            exit 1
        fi
    fi

    # Only clear screen in interactive terminals (not in CI)
    if [[ -t 1 ]] && command -v clear &>/dev/null; then
        clear
    fi
    print_header "ANSIBLE CONFIGURATION - INITIALIZATION SETUP"

    #################################################################################
    #                     STEP 1: INSTALL REQUIRED PACKAGES                         #
    #################################################################################

    print_step "1/5" "Installing Required System Packages"

    if [[ "$SKIP_INSTALL" != "true" ]]; then
        if ! install_packages; then
            exit 1
        fi
    else
        print_info "Skipping system package installation (--skip-install)"
    fi

    #################################################################################
    #                     STEP 2: SETUP PYTHON VENV & ANSIBLE                       #
    #################################################################################

    print_step "2/5" "Setting Up Python Virtual Environment"

    if ! setup_venv "$RECREATE_VENV"; then
        print_error "Failed to setup Python virtual environment"
        exit 1
    fi

    #################################################################################
    #              STEP 3: INSTALL ANSIBLE GALAXY COLLECTIONS                     #
    #################################################################################

    print_step "3/5" "Installing Ansible Galaxy Collections"

    if [[ "$SKIP_INSTALL" != "true" ]]; then
        install_collections
    else
        print_info "Skipping collection installation (--skip-install)"
    fi

    #################################################################################
    #                      STEP 4: DISPLAY AVAILABLE ROLES                        #
    #################################################################################

    print_step "4/5" "Available Roles"
    display_roles

    #################################################################################
    #                  STEP 5: RUN ANSIBLE PLAYBOOK                               #
    #################################################################################

    print_step "5/5" "Executing Ansible Playbook"

    if ! run_playbook; then
        exit 1
    fi
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
