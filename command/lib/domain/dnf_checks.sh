#!/bin/bash
# =============================================================================
# DNF Checks Domain
# Domain logic for DNF package manager validation
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Check if dnf is locked by another process
check_dnf_lock() {
    local lock_file="/var/cache/dnf/metadata_lock.pid"
    local max_wait=30
    local waited=0

    while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
        print_warn "DNF is locked by another process. Waiting... (${waited}s)"
        sleep 5
        waited=$((waited + 5))
    done

    if [[ -f "$lock_file" ]]; then
        print_error "DNF lock timeout. Please close Software Center or other package managers."
        return 1
    fi
    return 0
}
