#!/bin/bash
# =============================================================================
# Log Step Function
# Displays step progress messages in green
# =============================================================================

# Source colors if not already sourced
if [ -z "$GREEN" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

log_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}
