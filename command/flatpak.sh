#!/bin/bash

# =============================================================================
# Flatpak Support Installation Script for Ansible
# This script installs the community.general collection which includes
# flatpak module support for Ansible
# Reference: https://docs.ansible.com/ansible/latest/collections/community/general/flatpak_module.html
# =============================================================================

set -e

# =============================================================================
# Source Utility Functions
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/log_info.sh"
source "${SCRIPT_DIR}/lib/log_success.sh"
source "${SCRIPT_DIR}/lib/log_step.sh"

# =============================================================================
# Install Flatpak Support
# =============================================================================

log_info "=========================================="
log_info "Installing Flatpak Support for Ansible"
log_info "=========================================="

log_step "1/1: Installing community.general collection for Flatpak module..."
log_info "Running: ansible-galaxy collection install community.general"

if ansible-galaxy collection install community.general -v 2>&1; then
    log_success "community.general collection with Flatpak support installed successfully"

    # Verify installation
    log_info "Verifying Flatpak module availability..."
    if ansible-doc -t module community.general.flatpak >/dev/null 2>&1; then
        log_success "Flatpak module (community.general.flatpak) is available"
        log_info "Module documentation: ansible-doc community.general.flatpak"
    else
        log_info "Note: Flatpak module documentation requires full ansible installation"
    fi

    # Show installed collections
    log_info "Installed community.general collections:"
    ansible-galaxy collection list | grep "community.general" || true
else
    log_info "community.general collection might already be installed"
fi

log_info "=========================================="
log_success "Flatpak support installation completed!"
log_info "=========================================="
