#!/bin/bash
# =============================================================================
# Log Warning Function
# Displays warning messages in yellow
# =============================================================================

# Source colors if not already sourced
if [ -z "$YELLOW" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}
