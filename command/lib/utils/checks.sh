#!/bin/bash
# =============================================================================
# Pre-flight Checks Utilities
# Utility functions for system pre-flight validation
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/domain/system_checks.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Pre-flight system checks
preflight_check() {
    print_info "Running pre-flight system checks..."

    # Verify Fedora
    if ! verify_fedora; then
        return 1
    fi

    # Check disk space (1GB minimum)
    if ! check_disk_space 1000; then
        return 1
    fi

    # Check for active sudo session
    if ! sudo -n true 2>/dev/null; then
        print_warn "No active sudo session. You will be prompted for password."
    fi

    print_success "Pre-flight checks passed"
    return 0
}
