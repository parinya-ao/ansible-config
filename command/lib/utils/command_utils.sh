#!/bin/bash
# =============================================================================
# Command Utilities
# Utility functions for command execution and detection
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Run command silently and return status
run_silent() {
    "$@" &>/dev/null
}

# Run command with timeout protection
run_with_timeout() {
    local timeout_sec="$1"
    shift

    timeout "$timeout_sec" "$@" 2>&1
}
