#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - BOOTSTRAP SCRIPT                        #
#         Minimal bootstrapper for Fedora Workstation provisioning             #
#                                                                               #
# Philosophy: Use system Ansible package via DNF                               #
#################################################################################

set -euo pipefail

#################################################################################
#                                CONSTANTS                                       #
#################################################################################

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REQUIREMENTS="${PROGDIR}/requirements.yml"
readonly INVENTORY="${PROGDIR}/inventory"
readonly PLAYBOOK="${PROGDIR}/playbook.yaml"

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

# Step 1: Install Ansible via DNF
install_ansible() {
    print_step "Phase 1: Installing Ansible via DNF"

    if ! command -v ansible-playbook &> /dev/null; then
        echo "Installing ansible package..."
        sudo dnf install -y ansible
    else
        echo "Ansible already installed"
    fi
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
    install_ansible
    install_collections
    run_playbook "$@"
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
