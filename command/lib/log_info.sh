#!/bin/bash
# =============================================================================
# Log Info Function
# Displays informational messages in blue
# =============================================================================

# Source colors if not already sourced
if [ -z "$BLUE" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
