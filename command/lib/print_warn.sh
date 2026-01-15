#!/bin/bash
# =============================================================================
# Print Warning Message
# Usage: print_warn "Warning message"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_warn() {
    echo "  ${COLOR_YELLOW}${SYMBOL_INFO}${COLOR_RESET} ${COLOR_YELLOW}$1${COLOR_RESET}"
}
