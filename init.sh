#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - BOOTSTRAP SCRIPT                        #
#         Minimal bootstrapper for Fedora Workstation provisioning             #
#                                                                               #
# Philosophy: Use system Ansible package via DNF                               #
#                                                                               #
# ENABLED FEATURES:                                                             #
#   ✓ Common base configuration                                                 #
#   ✓ Locale settings (English)                                                 #
#   ✓ Git configuration with SSH signing                                       #
#   ✓ Stability and hardening                                                   #
#   ✓ Developer tools                                                           #
#   ✓ Multimedia codecs                                                         #
#   ✓ Embedded development (ARM, ESP)                                           #
#   ✗ NVIDIA drivers (DISABLED - enable manually if needed)                     #
#   ✗ Fonts (using separate script)                                             #
#   ✗ Power management (using system default)                                   #
#   ✓ Podman (pre-installed in Ultramarine)                                     #
#################################################################################

set -euo pipefail

#################################################################################
#                                CONSTANTS                                       #
#################################################################################

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REQUIREMENTS="${PROGDIR}/requirements.yml"
readonly INVENTORY="${PROGDIR}/inventory"
readonly PLAYBOOK="${PROGDIR}/playbook.yaml"

#################################################################################
#                              HELPER FUNCTIONS                                  #
#################################################################################

print_step() {
    echo ""
    echo "=== $1 ==="
}

print_error() {
    echo "[ERROR] $1" >&2
}

#################################################################################
#                         FEATURE FLAG CONFIGURATION                             #
#################################################################################

configure_feature_flags() {
    print_step "Phase 0: Configuring Feature Flags"

    # Export feature flags for Ansible playbook
    # All features ENABLED except NVIDIA drivers

    # Common role flags
    export COMMON_SYSTEM_UPDATE_ENABLED="${COMMON_SYSTEM_UPDATE_ENABLED:-true}"
    export COMMON_INSTALL_FISH="${COMMON_INSTALL_FISH:-true}"
    export COMMON_INSTALL_D2="${COMMON_INSTALL_D2:-true}"
    export COMMON_APPLY_OPTIMIZATIONS="${COMMON_APPLY_OPTIMIZATIONS:-true}"
    export COMMON_CONFIGURE_CUSTOM_DNS="${COMMON_CONFIGURE_CUSTOM_DNS:-true}"
    export COMMON_SET_UTC_TIME="${COMMON_SET_UTC_TIME:-false}"

    # NVIDIA drivers - DISABLED by default (enable manually if needed)
    export COMMON_INSTALL_NVIDIA_DRIVERS="${COMMON_INSTALL_NVIDIA_DRIVERS:-false}"
    export COMMON_ENABLE_RPM_FUSION="${COMMON_ENABLE_RPM_FUSION:-true}"

    # Locale role flags
    export LOCALE_INSTALL_GUI_TOOLS="${LOCALE_INSTALL_GUI_TOOLS:-false}"

    # Git role flags
    export GIT_CONFIGURE_SSH_SIGNING="${GIT_CONFIGURE_SSH_SIGNING:-true}"

    # Stability role flags
    export STABILITY_ENABLE_SNAPSHOTS="${STABILITY_ENABLE_SNAPSHOTS:-true}"

    # Developer role flags
    export DEVELOPER_INSTALL_NODEJS="${DEVELOPER_INSTALL_NODEJS:-true}"
    export DEVELOPER_INSTALL_RUST="${DEVELOPER_INSTALL_RUST:-true}"
    export DEVELOPER_INSTALL_GO="${DEVELOPER_INSTALL_GO:-true}"
    export DEVELOPER_INSTALL_PYTHON="${DEVELOPER_INSTALL_PYTHON:-true}"

    # Multimedia role flags
    export MULTIMEDIA_INSTALL_CODECS="${MULTIMEDIA_INSTALL_CODECS:-true}"

    # Embed role flags (STM32CubeMX removed)
    export EMBED_INSTALL_ARM_TOOLCHAIN="${EMBED_INSTALL_ARM_TOOLCHAIN:-true}"
    export EMBED_INSTALL_ESP_TOOLS="${EMBED_INSTALL_ESP_TOOLS:-true}"
    export EMBED_INSTALL_SERIAL_TOOLS="${EMBED_INSTALL_SERIAL_TOOLS:-true}"
    export EMBED_CONFIGURE_DIALOUT_GROUP="${EMBED_CONFIGURE_DIALOUT_GROUP:-true}"

    echo "Feature flags configured:"
    echo "  ✓ System updates: ${COMMON_SYSTEM_UPDATE_ENABLED}"
    echo "  ✓ Fish shell: ${COMMON_INSTALL_FISH}"
    echo "  ✓ D2 diagram compiler: ${COMMON_INSTALL_D2}"
    echo "  ✓ System optimizations: ${COMMON_APPLY_OPTIMIZATIONS}"
    echo "  ✓ Custom DNS: ${COMMON_CONFIGURE_CUSTOM_DNS}"
    echo "  ✗ NVIDIA drivers: ${COMMON_INSTALL_NVIDIA_DRIVERS} (DISABLED)"
    echo "  ✓ RPM Fusion: ${COMMON_ENABLE_RPM_FUSION}"
    echo "  ✓ ARM toolchain: ${EMBED_INSTALL_ARM_TOOLCHAIN}"
    echo "  ✓ ESP tools: ${EMBED_INSTALL_ESP_TOOLS}"
    echo "  ✓ Serial tools: ${EMBED_INSTALL_SERIAL_TOOLS}"
}

#################################################################################
#                              MAIN WORKFLOW                                     #
#################################################################################

# Global flags
SKIP_INSTALL=false
SKIP_CHECK=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --skip-check)
                SKIP_CHECK=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: $0 [--skip-install] [--skip-check]"
                exit 1
                ;;
        esac
    done
}

# Step 1: Install Ansible via DNF
install_ansible() {
    print_step "Phase 1: Installing Ansible via DNF"

    if ! command -v ansible-playbook &> /dev/null; then
        echo "Installing ansible package..."
        sudo dnf install -y ansible
    else
        echo "Ansible already installed"
    fi
}

# Step 2: Install Ansible Galaxy collections
install_collections() {
    print_step "Phase 2: Installing Ansible Collections"

    if [[ -f "$REQUIREMENTS" ]]; then
        echo "Installing collections from requirements.yml..."
        ansible-galaxy collection install -r "$REQUIREMENTS"
    else
        echo "No requirements.yml found, skipping collection install"
    fi
}

# Step 3: Hand off to Ansible
run_playbook() {
    # Skip playbook execution if --skip-install flag is set
    if [[ "$SKIP_INSTALL" == "true" ]]; then
        print_step "Skipping playbook execution (--skip-install specified)"
        return 0
    fi

    print_step "Phase 3: Handing off to Ansible"

    cd "$PROGDIR"

    # Pass remaining arguments to ansible-playbook
    # shellcheck disable=SC2086
    exec ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "$@"
}

#################################################################################
#                               MAIN ENTRY                                      #
#################################################################################

main() {
    parse_args "$@"
    configure_feature_flags
    install_ansible
    install_collections
    run_playbook
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
