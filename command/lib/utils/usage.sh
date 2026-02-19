#!/bin/bash
# =============================================================================
# Usage Utilities
# Utility functions for displaying usage information
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"

# Display usage information
usage() {
    cat <<EOF
Usage: ${PROGNAME} [OPTIONS]

Production-grade bootstrap script for Fedora Workstation Ansible configuration.
Installs Ansible in isolated Python venv, required collections, and runs playbook.

OPTIONS:
    -h, --help          Show this help message
    -s, --skip-install  Skip package installation
    -t, --tags-only     Run specific tags only (comma-separated)
    --dry-run           Perform a dry run (check mode)
    --recreate-venv     Recreate Python virtual environment from scratch
    --skip-check        Skip pre-flight system checks

EXAMPLES:
    ${PROGNAME}                 # Full installation
    ${PROGNAME} --skip-install  # Skip package install
    ${PROGNAME} -t common,docker # Run specific roles only
    ${PROGNAME} --dry-run       # Check without making changes
    ${PROGNAME} --recreate-venv # Fresh Python environment

EOF
}
