#!/bin/bash

################################################################################
#                     ANSIBLE CONFIG - INITIALIZATION SCRIPT                  #
#         This script sets up your system and runs the Ansible playbook       #
################################################################################

set -e

################################################################################
#                              LIBRARY LOADING                                #
################################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/command/lib"

# Check if library directory exists
if [ ! -d "$LIB_DIR" ]; then
    echo "Error: Library directory not found at $LIB_DIR"
    exit 1
fi

# Load helper functions
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/print_hr.sh"
source "${LIB_DIR}/print_header.sh"
source "${LIB_DIR}/print_step.sh"
source "${LIB_DIR}/print_info.sh"
source "${LIB_DIR}/print_success.sh"
source "${LIB_DIR}/print_warn.sh"
source "${LIB_DIR}/print_error.sh"
source "${LIB_DIR}/print_list.sh"

################################################################################
#                           UTILITY FUNCTIONS                                 #
################################################################################

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Run command silently
run_silent() {
    eval "$1" &>/dev/null
}

################################################################################
#                            MAIN EXECUTION                                   #
################################################################################

clear
print_header "ANSIBLE CONFIGURATION - INITIALIZATION SETUP"

################################################################################
#                     STEP 1: ENABLE CRB REPOSITORY                           #
################################################################################

print_step "1/7" "Enabling CRB Repository"
print_info "Checking and enabling CRB repository..."

if run_silent "sudo dnf config-manager --set-enabled crb"; then
    print_success "CRB repository is now enabled"
else
    print_warn "CRB repository already enabled or unavailable on this system"
fi

################################################################################
#                     STEP 2: INSTALL EPEL REPOSITORY                         #
################################################################################

print_step "2/7" "Installing EPEL Repository"
print_info "Checking and installing EPEL repository..."

if run_silent "sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm"; then
    print_success "EPEL repository installed successfully"
else
    print_warn "EPEL repository already installed on this system"
fi


################################################################################
#                   STEP 3: INSTALL REQUIRED PACKAGES                         #
################################################################################

print_step "3/7" "Installing Required Packages"

if command_exists git && command_exists ansible; then
    print_success "Git and Ansible are already installed"
else
    print_info "Installing Git and Ansible..."
    if sudo dnf install -y git ansible-core 2>&1 | tail -1 >/dev/null; then
        print_success "Required packages installed successfully"
    else
        print_error "Failed to install required packages"
        exit 1
    fi
fi

# Display version information
echo ""
if command_exists git; then
    print_info "Git version: $(git --version | cut -d' ' -f3)"
fi
if command_exists ansible; then
    print_info "Ansible version: $(ansible --version | head -n1 | sed 's/ansible \[core //;s/\]//')"
fi


################################################################################
#              STEP 4: INSTALL ANSIBLE GALAXY COLLECTIONS                     #
################################################################################

print_step "4/7" "Installing Ansible Galaxy Collections"
print_info "Installing community.general collection..."

if run_silent "ansible-galaxy collection install community.general"; then
    print_success "community.general collection installed successfully"
else
    print_success "community.general collection already installed"
fi


################################################################################
#                      STEP 5: DISPLAY AVAILABLE ROLES                        #
################################################################################

print_step "5/7" "Available Roles"
print_info "The following roles will be applied:"
echo ""

if [ -f "playbook.yaml" ]; then
    while IFS= read -r role; do
        role_name=$(echo "$role" | sed 's/.*role: *//' | sed 's/ *#.*//')
        [ -n "$role_name" ] && print_list "$role_name"
    done < <(grep -E "^\s+- role:" playbook.yaml 2>/dev/null)
else
    print_warn "playbook.yaml not found in current directory"
fi


################################################################################
#                      STEP 6: CONFIRMATION PROMPT                            #
################################################################################

print_step "6/7" "Ready to Begin"
echo ""
print_warn "You will be prompted to enter your sudo password"
echo ""
print_hr
echo ""
read -p "  ${COLOR_BOLD}Continue with installation?${COLOR_RESET} [${COLOR_GREEN}Y${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET}] " -n 1 -r
echo ""
echo ""

if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_warn "Installation aborted by user"
    exit 0
fi


################################################################################
#                  STEP 7: RUN ANSIBLE PLAYBOOK                               #
################################################################################

print_step "7/7" "Executing Ansible Playbook"
echo ""

if ansible-playbook playbook.yaml -K -vvv; then
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
else
    echo ""
    print_header "INSTALLATION FAILED"
    print_error "Please review the error messages above and try again"
    exit 1
fi
