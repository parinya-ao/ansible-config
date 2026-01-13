#!/bin/bash
# =============================================================================
# Print Step
# Usage: print_step "[1/5] Step description"
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

print_step() {
    local step_num="$1"
    local title="$2"

    echo ""
    if [ -n "$title" ]; then
         echo "${COLOR_BOLD}${COLOR_BLUE}[${step_num}]${COLOR_RESET} ${COLOR_BOLD}${title}${COLOR_RESET}"
    else
         echo "${COLOR_BOLD}${step_num}${COLOR_RESET}"
    fi
     echo "${COLOR_GRAY}------------------------------------------------------------------------${COLOR_RESET}"
}
