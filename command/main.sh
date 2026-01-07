#!/bin/bash

# =============================================================================
# Ansible Galaxy Collections Installation Script
# This script installs required Ansible collections for community.general
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
# Install Ansible Galaxy Collections
# =============================================================================

log_info "=========================================="
log_info "Installing Ansible Galaxy Collections"
log_info "=========================================="

# Step 1: Install community.general collection
log_step "1/2: Installing community.general collection..."
log_info "Running: ansible-galaxy collection install community.general"
if ansible-galaxy collection install community.general -v 2>&1; then
    log_success "community.general collection installed successfully"

    # Display installed collection info
    log_info "Collection info:"
    ansible-galaxy collection list | grep -A2 "community.general" || true
else
    log_info "community.general collection might already be installed"
fi

# Step 2: Install flatpak support (via community.general)
log_step "2/2: Installing flatpak support..."
log_info "Running: ./flatpak.sh"
chmod +x ./flatpak.sh
if ./flatpak.sh 2>&1; then
    log_success "flatpak support installed successfully"
else
    log_info "flatpak support might already be installed"
fi

log_info "=========================================="
log_success "Ansible Galaxy collections installation completed!"
log_info "=========================================="
