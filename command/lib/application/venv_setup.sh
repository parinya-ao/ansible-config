#!/bin/bash
# =============================================================================
# Virtual Environment Setup Application
# Application layer for Python virtual environment management
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/command_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/version_display.sh"

# Setup Python virtual environment
setup_venv() {
    local recreate="${1:-false}"

    # Check if venv already exists
    if [[ -d "$VENV_DIR" ]] && [[ "$recreate" != "true" ]]; then
        print_info "Virtual environment already exists at ${VENV_DIR}"
        source "${VENV_DIR}/bin/activate"

        # Verify Ansible is installed in venv
        if command_exists ansible; then
            local version
            version=$(ansible --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+' | head -1)
            print_success "Ansible ${version:-unknown} found in venv"
            return 0
        else
            print_warn "Venv exists but Ansible not found. Recreating..."
            recreate=true
        fi
    fi

    # Create or recreate venv
    if [[ "$recreate" == "true" ]] && [[ -d "$VENV_DIR" ]]; then
        print_info "Removing existing virtual environment..."
        rm -rf "$VENV_DIR"
    fi

    print_info "Creating Python virtual environment at ${VENV_DIR}..."

    if ! python3 -m venv "$VENV_DIR"; then
        print_error "Failed to create virtual environment"
        return 1
    fi

    source "${VENV_DIR}/bin/activate"

    print_info "Installing Ansible ${ANSIBLE_VERSION}.x in venv..."

    # Upgrade pip first
    if ! pip install --upgrade pip --quiet; then
        print_error "Failed to upgrade pip"
        return 1
    fi

    # Install Ansible pinned to the configured major.minor version
    if ! pip install --quiet "ansible-core>=${ANSIBLE_VERSION},<$(echo "${ANSIBLE_VERSION}" | awk -F. '{print $1"."$2+1}')"; then
        print_error "Failed to install Ansible in venv"
        return 1
    fi

    print_success "Ansible installed in isolated environment"
    display_versions
    return 0
}
