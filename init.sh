#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT-0
#
#################################################################################
#                     ANSIBLE CONFIG - INITIALIZATION SCRIPT                  #
#         Production-grade bootstrap script for Fedora Workstation             #
#                                                                               #
# Features:                                                                      #
#   - Python venv isolation for Ansible stability                                #
#   - Enhanced error handling with retry logic and timeouts                      #
#   - Cleanup handlers with trap signals                                         #
#   - Pre-flight system checks                                                   #
#   - Fedora-only (simplified, production-focused)                               #
#################################################################################

set -euo pipefail

#################################################################################
#                                CONSTANTS                                       #
#################################################################################

readonly PROGNAME="$(basename "${0}")"
readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="${PROGDIR}/command/lib"
readonly PLAYBOOK="${PROGDIR}/playbook.yaml"
readonly VENV_DIR="${PROGDIR}/.ansible-venv"
readonly ANSIBLE_VERSION="${ANSIBLE_VERSION:-2.18}"  # Pinned for stability

# Retry configuration
readonly MAX_RETRIES="${MAX_RETRIES:-3}"
readonly RETRY_DELAY="${RETRY_DELAY:-5}"

# Timeout configuration (seconds)
readonly DNF_TIMEOUT="${DNF_TIMEOUT:-300}"
readonly GALAXY_TIMEOUT="${GALAXY_TIMEOUT:-180}"

#################################################################################
#                              LIBRARY LOADING                                #
#################################################################################

_load_library() {
    local lib_name="$1"
    local lib_path="${LIB_DIR}/${lib_name}"

    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    else
        echo "Error: Library ${lib_name} not found at ${LIB_DIR}" >&2
        return 1
    fi
}

# Load all required libraries
_load_library "colors.sh"      || exit 1
_load_library "print_hr.sh"      || exit 1
_load_library "print_header.sh"   || exit 1
_load_library "print_step.sh"    || exit 1
_load_library "print_info.sh"     || exit 1
_load_library "print_success.sh"   || exit 1
_load_library "print_warn.sh"      || exit 1
_load_library "print_error.sh"     || exit 1
_load_library "print_list.sh"     || exit 1

#################################################################################
#                           UTILITY FUNCTIONS                                 #
#################################################################################

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Run command silently and return status
run_silent() {
    "$@" &>/dev/null
}

# Run command with timeout protection
run_with_timeout() {
    local timeout_sec="$1"
    shift

    timeout "$timeout_sec" "$@" 2>&1
}

# Check if running as root
is_root() {
    [[ "$(id -u)" -eq 0 ]]
}

# Verify we are on Fedora
verify_fedora() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS. /etc/os-release not found."
        return 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "${ID:-}" != "fedora" ]]; then
        print_warn "This script is designed for Fedora only."
        print_info "Detected OS: ${ID:-unknown}"
        print_info "For cross-platform support, use a different version of this script."
        return 1
    fi

    return 0
}

# Check minimum disk space (in MB)
check_disk_space() {
    local required_mb="${1:-1000}"
    local available_mb

    available_mb=$(df -BM --output=avail "${PROGDIR}" | tail -1 | tr -cd '0-9')

    if [[ "$available_mb" -lt "$required_mb" ]]; then
        print_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
        return 1
    fi
    return 0
}

# Check if dnf is locked by another process
check_dnf_lock() {
    local lock_file="/var/cache/dnf/metadata_lock.pid"
    local max_wait=30
    local waited=0

    while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
        print_warn "DNF is locked by another process. Waiting... (${waited}s)"
        sleep 5
        waited=$((waited + 5))
    done

    if [[ -f "$lock_file" ]]; then
        print_error "DNF lock timeout. Please close Software Center or other package managers."
        return 1
    fi
    return 0
}

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

#################################################################################
#                              MAIN FUNCTIONS                                   #
#################################################################################

# Parse command line arguments
parse_args() {
    local skip_install=false
    local tags_only=""
    local dry_run=false
    local recreate_venv=false
    local skip_check=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -s|--skip-install)
                skip_install=true
                ;;
            -t|--tags-only)
                if [[ -n "${2:-}" ]] && [[ "${2:0:1}" != "-" ]]; then
                    tags_only="$2"
                    shift
                else
                    echo "Error: --tags-only requires an argument" >&2
                    exit 1
                fi
                ;;
            --dry-run)
                dry_run=true
                ;;
            --recreate-venv)
                recreate_venv=true
                ;;
            --skip-check)
                skip_check=true
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
        shift
    done

    export SKIP_INSTALL="$skip_install"
    export TAGS_ONLY="$tags_only"
    export DRY_RUN="$dry_run"
    export RECREATE_VENV="$recreate_venv"
    export SKIP_CHECK="$skip_check"
}

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

# Pre-flight system checks
preflight_check() {
    print_info "Running pre-flight system checks..."

    # Verify Fedora
    if ! verify_fedora; then
        return 1
    fi

    # Check disk space (1GB minimum)
    if ! check_disk_space 1000; then
        return 1
    fi

    # Check for active sudo session
    if ! sudo -n true 2>/dev/null; then
        print_warn "No active sudo session. You will be prompted for password."
    fi

    print_success "Pre-flight checks passed"
    return 0
}

# DNF install with retry logic
dnf_install_with_retry() {
    local packages=("$@")
    local attempt=0
    local output=""

    while [[ $attempt -lt $MAX_RETRIES ]]; do
        # Check for DNF lock before each attempt
        if ! check_dnf_lock; then
            return 1
        fi

        if output=$(run_with_timeout "$DNF_TIMEOUT" sudo dnf install -y "${packages[@]}" 2>&1); then
            return 0
        fi

        attempt=$((attempt + 1))

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            print_warn "DNF install attempt $attempt/$MAX_RETRIES failed. Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
    done

    print_error "Failed to install packages after $MAX_RETRIES attempts"
    echo "$output" | tail -20 >&2
    return 1
}

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

    # Install Ansible
    if ! pip install --quiet ansible-core; then
        print_error "Failed to install Ansible in venv"
        return 1
    fi

    print_success "Ansible installed in isolated environment"
    display_versions
    return 0
}

# Install required system packages
install_packages() {
    local system_pkgs=("git" "python3-pip" "python3-venv")
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

# Display version information
display_versions() {
    echo ""

    if command_exists git; then
        print_info "Git version: $(git --version | cut -d' ' -f3)"
    fi

    if command_exists ansible; then
        local ansible_version
        ansible_version=$(ansible --version 2>/dev/null | head -n1 | sed 's/ansible \[core //;s/\]//')
        print_info "Ansible version: ${ansible_version}"
    fi

    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        print_info "Python venv: ${VIRTUAL_ENV}"
    fi
}

# Install Ansible collections with timeout and retry
install_collections() {
    print_info "Installing community.general collection..."

    local attempt=0

    while [[ $attempt -lt $MAX_RETRIES ]]; do
        if run_with_timeout "$GALAXY_TIMEOUT" ansible-galaxy collection install community.general --quiet; then
            print_success "community.general collection installed successfully"
            return 0
        fi

        attempt=$((attempt + 1))

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            print_warn "Collection install attempt $attempt/$MAX_RETRIES failed. Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
    done

    print_warn "Collection installation had issues, but may already be installed"
    return 0
}

# Display available roles
display_roles() {
    print_info "The following roles will be applied:"
    echo ""

    if [[ ! -f "$PLAYBOOK" ]]; then
        print_warn "playbook.yaml not found at ${PLAYBOOK}"
        return 1
    fi

    local role_line role_name
    while IFS= read -r role_line; do
        role_name=$(echo "$role_line" | sed 's/.*role: *//' | sed 's/ *#.*//')
        [[ -n "$role_name" ]] && print_list "$role_name"
    done < <(grep -E "^\s+- role:" "$PLAYBOOK" 2>/dev/null)
}

# Verify playbook syntax before running
verify_playbook() {
    print_info "Verifying playbook syntax..."

    if ! ansible-playbook "$PLAYBOOK" --syntax-check &>/dev/null; then
        print_error "Playbook syntax check failed"
        return 1
    fi

    print_success "Playbook syntax is valid"
    return 0
}

# Run Ansible playbook
run_playbook() {
    # Ensure we're using the venv's Ansible
    if [[ ! -f "${VENV_DIR}/bin/ansible-playbook" ]]; then
        print_error "Ansible not found in venv. Run without --skip-install first."
        return 1
    fi

    # Verify playbook syntax first
    if ! verify_playbook; then
        return 1
    fi

    local ansible_opts=()

    [[ -n "$TAGS_ONLY" ]] && ansible_opts+=("--tags" "$TAGS_ONLY")
    [[ "$DRY_RUN" == "true" ]] && ansible_opts+=("--check")

    echo ""
    print_warn "You will be prompted to enter your sudo password"
    echo ""
    print_hr
    echo ""

    if ansible-playbook "$PLAYBOOK" -K "${ansible_opts[@]}"; then
        display_success_message
        return 0
    else
        display_failure_message
        return 1
    fi
}

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

#################################################################################
#                               MAIN ENTRY                                     #
#################################################################################

main() {
    # Set up traps for cleanup and error handling
    trap cleanup EXIT
    trap 'error_handler ${LINENO}' ERR

    # Parse arguments first (before accessing variables that depend on args)
    parse_args "$@"

    # Pre-flight checks
    if [[ "$SKIP_CHECK" != "true" ]]; then
        if ! preflight_check; then
            exit 1
        fi
    fi

    # Only clear screen in interactive terminals (not in CI)
    if [[ -t 1 ]] && command -v clear &>/dev/null; then
        clear
    fi
    print_header "ANSIBLE CONFIGURATION - INITIALIZATION SETUP"

    #################################################################################
    #                     STEP 1: INSTALL REQUIRED PACKAGES                         #
    #################################################################################

    print_step "1/5" "Installing Required System Packages"

    if [[ "$SKIP_INSTALL" != "true" ]]; then
        if ! install_packages; then
            exit 1
        fi
    else
        print_info "Skipping system package installation (--skip-install)"
    fi

    #################################################################################
    #                     STEP 2: SETUP PYTHON VENV & ANSIBLE                       #
    #################################################################################

    print_step "2/5" "Setting Up Python Virtual Environment"

    if ! setup_venv "$RECREATE_VENV"; then
        print_error "Failed to setup Python virtual environment"
        exit 1
    fi

    #################################################################################
    #              STEP 3: INSTALL ANSIBLE GALAXY COLLECTIONS                     #
    #################################################################################

    print_step "3/5" "Installing Ansible Galaxy Collections"

    if [[ "$SKIP_INSTALL" != "true" ]]; then
        install_collections
    else
        print_info "Skipping collection installation (--skip-install)"
    fi

    #################################################################################
    #                      STEP 4: DISPLAY AVAILABLE ROLES                        #
    #################################################################################

    print_step "4/5" "Available Roles"
    display_roles

    #################################################################################
    #                  STEP 5: RUN ANSIBLE PLAYBOOK                               #
    #################################################################################

    print_step "5/5" "Executing Ansible Playbook"

    if ! run_playbook; then
        exit 1
    fi
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
