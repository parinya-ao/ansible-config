#!/bin/bash
# =============================================================================
# Message Display Utilities
# Utility functions for displaying success and failure messages
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Display success message
display_success_message() {
    echo ""
    print_header "INSTALLATION COMPLETED SUCCESSFULLY"
    echo ""
    print_info "Next steps:"
    print_list "Log out and back in for group changes to take effect (docker group)"
    print_list "Run: ${COLOR_BOLD}docker --version${COLOR_RESET} to verify Docker installation"
    print_list "Run: ${COLOR_BOLD}node --version${COLOR_RESET} to verify Node.js installation"
    print_list "Run: ${COLOR_BOLD}cargo --version${COLOR_RESET} to verify Rust installation"
    print_list "Run: ${COLOR_BOLD}flatpak list${COLOR_RESET} to see installed Flatpak applications"
    echo ""

    if [[ -d "$VENV_DIR" ]]; then
        print_info "Ansible is isolated in: ${VENV_DIR}"
        print_info "To use Ansible outside this script: source ${VENV_DIR}/bin/activate"
    fi
    echo ""
}

# Display failure message
display_failure_message() {
    echo ""
    print_header "INSTALLATION FAILED"
    print_error "Please review error messages above and try again"
    print_info "Tip: Use --recreate-venv to start with a fresh Python environment"
}
