#!/bin/bash
# =============================================================================
# Print Separator Line
# Usage: print_separator
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_separator() {
    echo ""
    echo "${COLOR_GRAY}─────────────────────────────────────────────────────────────────${COLOR_RESET}"
}
