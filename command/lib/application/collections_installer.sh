#!/bin/bash
# =============================================================================
# Collections Installer Application
# Application layer for Ansible Galaxy collections management
# =============================================================================
# SPDX-License-Identifier: MIT-0

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Install Ansible collections from requirements.yml with timeout and retry
install_collections() {
    local requirements_file="${PROGDIR}/requirements.yml"

    if [[ ! -f "$requirements_file" ]]; then
        print_warn "No requirements.yml found at ${requirements_file}, skipping collection install"
        return 0
    fi

    print_info "Installing Ansible collections from requirements.yml..."

    local attempt=0

    while [[ $attempt -lt $MAX_RETRIES ]]; do
        if run_with_timeout "$GALAXY_TIMEOUT" \
            ansible-galaxy collection install -r "$requirements_file"; then
            print_success "Ansible collections installed successfully"
            return 0
        fi

        attempt=$((attempt + 1))

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            print_warn "Collection install attempt $attempt/$MAX_RETRIES failed. Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
    done

    print_warn "Collection installation had issues, but collections may already be installed"
    return 0
}
