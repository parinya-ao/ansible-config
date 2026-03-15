# SPDX-License-Identifier: MIT-0

# CLAUDE.md - Ansible Fedora Workstation Configuration

## WHAT: Project Overview

**Purpose**: Infrastructure-as-Code for Fedora Workstation automation using Ansible.

**Tech Stack**:
- Ansible 2.15+ (DNF5-compatible)
- Target: Fedora Linux 41+ (Rawhide)
- Local execution with sudo privileges
- GitHub Actions CI/CD

**Project Structure**:
```
site.yml                 # Entry point (ansible-creator standard)
playbook.yaml            # Main playbook (9 roles)
init.sh                  # Bootstrap script (installs Ansible via DNF)
collections/             # Ansible collections
  └── local/workstation/ # Our collection (10 roles)
      └── roles/
          ├── common/         # Base system (DNF, RPM Fusion, updates)
          ├── locale/         # English environment
          ├── git/            # Git + SSH signing
          ├── stability/      # dnf-automatic, firewalld, sysctl
          ├── developer/      # Compilers, runtimes, SDKs
          ├── font/           # Programming + Thai fonts
          ├── power/          # TLP power management
          ├── multimedia/     # Codecs, hardware acceleration
          ├── embed/          # ARM GCC, ESP-IDF, serial tools
          └── docker/         # Docker/Podman setup
.github/workflows/       # CI: security scan, lint, idempotence test
```

## WHY: Architecture & Purpose

**Design Philosophy**:
- Agentless configuration management (push-based)
- Idempotent operations (safe to run multiple times)
- Modular roles with feature toggles
- CI-enforced quality (ansible-lint production profile)

**Key Decisions**:
- Uses system Ansible via DNF (not pip)
- Collections installed via `requirements.yml`
- Feature flags via environment variables in `init.sh`
- Recovery system with error logging to `/var/log/ansible_recovery_*.marker`

## HOW: Working on This Project

### Essential Commands

```bash
# Bootstrap and run (recommended)
./init.sh

# Run specific roles
ansible-playbook site.yml -i inventory/hosts --tags developer,font

# Syntax check
ansible-playbook --syntax-check site.yml

# Check mode (dry run)
ansible-playbook site.yml -i inventory/hosts --check

# Lint (REQUIRED before commit)
ansible-lint --profile production --fix

# YAML lint
yamllint -c .yamllint .
```

### Testing Changes

1. **Syntax**: `ansible-playbook --syntax-check site.yml`
2. **Lint**: `ansible-lint --profile production`
3. **Idempotence**: Run playbook twice - second run should show 0 changed
4. **CI**: GitHub Actions runs on Fedora Rawhide container

### Code Conventions

- **Variable naming**: Use role prefix (`common_*`, `developer_*`, `font_*`)
- **License header**: `SPDX-License-Identifier: MIT-0`
- **Structure**: Standard Ansible role layout
- **Blocks**: Use `block:` keyword (NOT `ansible.builtin.block:`)
- **Error handling**: Use `rescue:` and `always:` blocks for recovery

### Feature Toggles

Override in `init.sh` or via CLI `-e`:
```bash
# Disable NVIDIA drivers (default: false)
-e "common_install_nvidia_drivers=false"

# Disable Flutter (default: true)
-e "developer_install_flutter=false"

# Enable TLP (default: true)
-e "power_install_tlp=true"
```

## Progressive Disclosure

For detailed context, read these files when working on specific areas:

- **ARCHITECTURE.md** - Complete system architecture, data flow, security
- **roles/<name>/README.md** - Role-specific documentation
- **roles/<name>/defaults/main.yml** - Feature toggles and variables
- **.github/workflows/ci.yml** - CI/CD pipeline details
- **ansible.cfg** - Ansible configuration (fact caching, logging)

## CI/CD Status

**Workflows** (`.github/workflows/`):
- `ci.yml` - Security scan (TruffleHog + Checkov), lint, Fedora Rawhide test
- `tests.yml` - ansible-lint, yamllint, syntax check, check mode

**Requirements**:
- All PRs must pass CI (Tests + Ansible CI Pipeline)
- ansible-lint production profile enforced
- Idempotence check allows ≤10 changed tasks (systemd quirks)

## Known Issues & Workarounds

1. **Checkov alerts**: 5 warnings for webhook URLs (user-configurable via variables)
2. **Idempotence**: Locale role has minor issues (10 changed tasks allowed)
3. **Molecule tests**: Disabled in CI (Podman-in-Docker limitation)
4. **Systemd tasks**: Skip in CI containers (no PID 1 systemd)

## Quick Reference

| Task | Command |
|------|---------|
| Add new role | Create in `collections/ansible_collections/local/workstation/roles/` |
| Run single role | `ansible-playbook site.yml --tags <role>` |
| Debug variable | `ansible.builtin.debug: var: role_prefix_var` |
| Fix lint errors | `ansible-lint --profile production --fix` |
| View task logs | `cat ansible.log` |
| Recovery logs | `cat /var/log/ansible_recovery_*.marker` |
