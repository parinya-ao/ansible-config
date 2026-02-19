#!/bin/bash
# =============================================================================
# Version Display Utilities
# Utility functions for displaying version information
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Display version information
display_versions() {
    echo ""

    if command_exists git; then
        print_info "Git version: $(git --version | cut -d' ' -f3)"
    fi

    if command_exists ansible; then
        local ansible_version
        ansible_version=$(ansible --version 2>/dev/null | head -n1 | sed 's/ansible \[core //;s/\]//')
        print_info "Ansible version: ${ansible_version}"
    fi

    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        print_info "Python venv: ${VIRTUAL_ENV}"
    fi
}
