#!/bin/bash
# =============================================================================
# Print List Item
# Usage: print_list "List item text"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_list() {
    echo "  ${COLOR_GRAY}${SYMBOL_BULLET}${COLOR_RESET} $1"
}
