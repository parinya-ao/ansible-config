#!/bin/bash
# =============================================================================
# Ansible Galaxy Collections Installation Script
# Installs required Ansible collections for the playbook
# =============================================================================

set -e

# =============================================================================
# Source Utility Functions
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/print_header.sh"
source "${SCRIPT_DIR}/lib/print_step.sh"
source "${SCRIPT_DIR}/lib/print_info.sh"
source "${SCRIPT_DIR}/lib/print_success.sh"
source "${SCRIPT_DIR}/lib/print_warn.sh"

# =============================================================================
# Install Ansible Galaxy Collections
# =============================================================================

print_header "Installing Ansible Galaxy Collections"

# Install community.general collection
print_step "1/1: Installing community.general collection..."
print_info "Running: ansible-galaxy collection install community.general"

if ansible-galaxy collection install community.general >/dev/null 2>&1; then
    print_success "community.general collection installed"
else
    print_warn "community.general already installed"
fi

print_header "Installation Complete"
