#!/bin/bash
# =============================================================================
# System Checks Domain
# Domain logic for system validation and verification
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Check if running as root
is_root() {
    [[ "$(id -u)" -eq 0 ]]
}

# Verify we are on Fedora
verify_fedora() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS. /etc/os-release not found."
        return 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "${ID:-}" != "fedora" ]]; then
        print_warn "This script is designed for Fedora only."
        print_info "Detected OS: ${ID:-unknown}"
        print_info "For cross-platform support, use a different version of this script."
        return 1
    fi

    return 0
}

# Check minimum disk space (in MB)
check_disk_space() {
    local required_mb="${1:-1000}"
    local available_mb

    available_mb=$(df -BM --output=avail "${PROGDIR}" | tail -1 | tr -cd '0-9')

    if [[ "$available_mb" -lt "$required_mb" ]]; then
        print_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
        return 1
    fi
    return 0
}
