#!/bin/bash
# =============================================================================
# DNF Installer Infrastructure
# Infrastructure layer for DNF package installation
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/domain/dnf_checks.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# DNF install with retry logic
dnf_install_with_retry() {
    local packages=("$@")
    local attempt=0
    local output=""

    while [[ $attempt -lt $MAX_RETRIES ]]; do
        # Check for DNF lock before each attempt
        if ! check_dnf_lock; then
            return 1
        fi

        if output=$(run_with_timeout "$DNF_TIMEOUT" sudo dnf install -y "${packages[@]}" 2>&1); then
            return 0
        fi

        attempt=$((attempt + 1))

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            print_warn "DNF install attempt $attempt/$MAX_RETRIES failed. Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
    done

    print_error "Failed to install packages after $MAX_RETRIES attempts"
    echo "$output" | tail -20 >&2
    return 1
}
