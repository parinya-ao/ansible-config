#!/bin/bash
# =============================================================================
# Package Installer Application
# Application layer for system package installation
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/infrastructure/dnf_installer.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Install required system packages
install_packages() {
    local system_pkgs=("git" "python3-pip")
    local missing_pkgs=()
    local pkg

    # Check for missing packages
    for pkg in "${system_pkgs[@]}"; do
        if ! command_exists "$pkg" && ! rpm -q "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    # Python venv module is provided by python3-libs, check differently
    if ! python3 -m venv --help &>/dev/null; then
        missing_pkgs+=("python3-venv")
    fi

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        print_success "System packages already installed"
        return 0
    fi

    print_info "Installing system packages: ${missing_pkgs[*]}"

    if ! dnf_install_with_retry "${missing_pkgs[@]}"; then
        print_error "Failed to install required system packages"
        return 1
    fi

    print_success "System packages installed successfully"
    return 0
}
