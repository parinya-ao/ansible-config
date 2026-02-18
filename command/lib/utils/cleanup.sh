#!/bin/bash
# =============================================================================
# Cleanup Utilities
# Utility functions for cleanup and error handling
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Cleanup function for trap handler
cleanup() {
    local exit_code=$?

    # Deactivate venv if active
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        deactivate 2>/dev/null || true
    fi

    # Clean up any temporary files
    if [[ -n "${TEMP_FILES_CREATED:-}" ]]; then
        for tmp_file in $TEMP_FILES_CREATED; do
            rm -f "$tmp_file" 2>/dev/null || true
        done
    fi

    # Only print message on error
    if [[ $exit_code -ne 0 ]] && [[ $exit_code -ne 130 ]]; then  # 130 = Ctrl+C
        print_error "Script exited with error code: $exit_code"
    fi
}

# Error handler for traps
error_handler() {
    local line_no=$1
    print_error "Error occurred in script at line: $line_no"
}
