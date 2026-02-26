#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - BOOTSTRAP SCRIPT                        #
#         Minimal bootstrapper for Fedora Workstation provisioning             #
#                                                                               #
# Philosophy: Bash handles environment setup only. Ansible handles all logic.  #
#################################################################################

set -euo pipefail

#################################################################################
#                                CONSTANTS                                       #
#################################################################################

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VENV_DIR="${PROGDIR}/.ansible-venv"
readonly REQUIREMENTS="${PROGDIR}/requirements.yml"
readonly INVENTORY="${PROGDIR}/inventory"
readonly PLAYBOOK="${PROGDIR}/playbook.yaml"
readonly ANSIBLE_VERSION="${ANSIBLE_VERSION:-2.18}"

#################################################################################
#                              HELPER FUNCTIONS                                  #
#################################################################################

print_step() {
    echo ""
    echo "=== $1 ==="
}

print_error() {
    echo "[ERROR] $1" >&2
}

#################################################################################
#                              MAIN WORKFLOW                                     #
#################################################################################

# Step 1: Bootstrap Python virtual environment
setup_venv() {
    print_step "Phase 1: Bootstrapping Python Environment"

    # Verify venv integrity, not just directory existence
    if [[ ! -f "${VENV_DIR}/bin/activate" ]]; then
        echo "Virtual environment missing or invalid. Recreating..."
        rm -rf "$VENV_DIR"
        python3 -m venv "$VENV_DIR"
    else
        echo "Virtual environment exists at ${VENV_DIR}"
    fi

    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"

    # Ensure we are actually in the venv before proceeding
    if [[ "$VIRTUAL_ENV" != "$VENV_DIR" ]]; then
        print_error "Failed to activate virtual environment."
        exit 1
    fi

    echo "Upgrading pip and installing ansible-core..."
    # Combine installations to reduce round-trips
    pip install --quiet --upgrade pip "ansible-core>=${ANSIBLE_VERSION},<2.19"
}

# Step 2: Install Ansible Galaxy collections
install_collections() {
    print_step "Phase 2: Installing Ansible Collections"

    if [[ -f "$REQUIREMENTS" ]]; then
        echo "Installing collections from requirements.yml..."
        ansible-galaxy collection install -r "$REQUIREMENTS" --force || true
    else
        echo "No requirements.yml found, skipping collection install"
    fi
}

# Step 3: Hand off to Ansible
run_playbook() {
    print_step "Phase 3: Handing off to Ansible"

    cd "$PROGDIR"

    # Pass all script arguments to ansible-playbook
    # shellcheck disable=SC2086
    exec ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "$@"
}

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
