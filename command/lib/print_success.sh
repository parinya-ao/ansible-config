#!/bin/bash
# =============================================================================
# Print Success Message
# Usage: print_success "Success message"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_success() {
    echo "  ${COLOR_GREEN}${SYMBOL_TICK}${COLOR_RESET} ${COLOR_GREEN}$1${COLOR_RESET}"
}
