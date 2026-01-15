#!/bin/bash
# =============================================================================
# Color Definitions
# ANSI color codes and Unicode symbols for terminal output
# =============================================================================

readonly COLOR_RESET=$'\033[0m'
readonly COLOR_BOLD=$'\033[1m'
readonly COLOR_DIM=$'\033[2m'
readonly COLOR_GREEN=$'\033[0;32m'
readonly COLOR_BLUE=$'\033[0;34m'
readonly COLOR_CYAN=$'\033[0;36m'
readonly COLOR_YELLOW=$'\033[1;33m'
readonly COLOR_RED=$'\033[0;31m'
readonly COLOR_GRAY=$'\033[0;90m'

readonly SYMBOL_TICK='[OK]'
readonly SYMBOL_CROSS='[ERROR]'
readonly SYMBOL_ARROW='INFO:'
readonly SYMBOL_BULLET='*'
readonly SYMBOL_INFO='[WARN]'
