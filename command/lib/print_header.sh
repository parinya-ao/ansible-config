#!/bin/bash
# =============================================================================
# Print Section Header
# Usage: print_header "Section Title"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/print_hr.sh"

print_header() {
    local text="$1"
    echo ""
    print_hr
    echo "  ${COLOR_BOLD}${text}${COLOR_RESET}"
    print_hr
}
