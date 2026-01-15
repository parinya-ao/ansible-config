#!/bin/bash
# =============================================================================
# Print Error Message
# Usage: print_error "Error message"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_error() {
    echo "  ${COLOR_RED}${SYMBOL_CROSS}${COLOR_RESET} ${COLOR_RED}$1${COLOR_RESET}"
}
