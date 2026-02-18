#!/bin/bash
# =============================================================================
# Playbook Runner Application
# Application layer for Ansible playbook execution
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/messages.sh"

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
