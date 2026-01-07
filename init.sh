#!/bin/bash

# =============================================================================
# Ansible Config Initialization Script
# This script sets up the system and runs the Ansible playbook
# =============================================================================

set -e

# =============================================================================
# Source Utility Functions
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/command/lib/colors.sh"
source "${SCRIPT_DIR}/command/lib/log_info.sh"
source "${SCRIPT_DIR}/command/lib/log_success.sh"
source "${SCRIPT_DIR}/command/lib/log_step.sh"
source "${SCRIPT_DIR}/command/lib/log_warn.sh"

# =============================================================================
# Main Installation Process
# =============================================================================

log_info "=========================================="
log_info "Ansible Config - Initialization Script"
log_info "=========================================="

# Step 1: Enable CRB repository
log_step "1/6: Enabling CRB repository..."
log_info "Running: dnf config-manager --set-enabled crb"
if dnf config-manager --set-enabled crb 2>&1; then
    log_success "CRB repository enabled successfully"
else
    log_warn "CRB repository might already be enabled or unavailable"
fi

# Step 2: Install EPEL repository
log_step "2/6: Installing EPEL repository..."
log_info "Running: dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm"
if sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y 2>&1; then
    log_success "EPEL repository installed successfully"
else
    log_warn "EPEL repository might already be installed"
fi

# Step 3: Install required packages (git, ansible-core)
log_step "3/6: Installing git and ansible-core..."
log_info "Running: sudo dnf install git ansible-core -y"
if sudo dnf install git ansible-core -y 2>&1; then
    log_success "Required packages installed successfully"
    log_info "Git version: $(git --version 2>/dev/null || echo 'Not found')"
    log_info "Ansible Core version: $(ansible --version 2>/dev/null | head -n1 || echo 'Not found')"
else
    log_warn "Required packages might already be installed"
fi

# Step 4: Install Ansible Galaxy collections
log_step "4/6: Installing Ansible Galaxy collections..."
log_info "Running: ./command/main.sh"
chmod +x ./command/main.sh
if ./command/main.sh 2>&1; then
    log_success "Ansible Galaxy collections installed successfully"
else
    log_warn "Ansible Galaxy collections installation might have issues"
fi

# Step 5: Display playbook information
log_step "5/6: Displaying playbook information..."
log_info "Playbook: playbook.yaml"
log_info "Target: localhost"
log_info "Roles to be applied:"
grep -E "^\s+- role:" playbook.yaml | sed 's/^[[:space:]]*/  - /' || echo "  (Unable to read roles)"

# Step 6: Run Ansible playbook
log_step "6/6: Running Ansible playbook..."
log_info "Running: ansible-playbook playbook.yaml -K -v"
log_warn "You will be prompted for sudo password..."
echo ""
log_info "=========================================="
log_info "Ansible Playbook Execution"
log_info "=========================================="
echo ""

if ansible-playbook playbook.yaml -K -v 2>&1; then
    echo ""
    log_info "=========================================="
    log_success "Ansible playbook completed successfully!"
    log_info "=========================================="
else
    echo ""
    log_info "=========================================="
    log_warn "Ansible playbook completed with errors"
    log_info "=========================================="
    exit 1
fi
