#!/bin/bash
# =============================================================================
# Log Success Function
# Displays success messages in green
# =============================================================================

# Source colors if not already sourced
if [ -z "$GREEN" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}
