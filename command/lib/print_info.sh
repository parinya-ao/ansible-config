#!/bin/bash
# =============================================================================
# Print Info Message
# Usage: print_info "Information message"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_info() {
    echo "  ${COLOR_GRAY}${SYMBOL_ARROW} $1${COLOR_RESET}"
}
