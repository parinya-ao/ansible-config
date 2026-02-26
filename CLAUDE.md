# SPDX-License-Identifier: MIT-0
# Ansible Fedora Workstation Configuration

## Purpose
Automated Fedora Workstation provisioning using Ansible. Transforms a fresh Fedora installation into a fully configured development environment.

## Quick Start

```bash
# Run complete playbook (Ansible must be installed)
ansible-playbook playbook.yaml -i inventory.ini

# Bootstrap + run (installs Ansible via pip if missing)
./init.sh

# Run specific roles only
ansible-playbook playbook.yaml -i inventory.ini --tags common,docker

# Lint before committing
ansible-lint --profile production --fix roles/
```

## Project Structure

```
playbook.yaml          # Main entry point
init.sh                # Bootstrap script
requirements.yml       # Collection dependencies
roles/                 # Ansible roles (common, locale, desktop, developer, docker, git, font, wifi, multimedia)
.github/workflows/     # CI/CD (security scan, lint, idempotence test)
```

## How It Works
- **Target**: Fedora Workstation 41+ (DNF5-based)
- **Connection**: Local only (`ansible_connection=local`)
- **Privileges**: Requires `sudo` for system changes
- **Idempotence**: All roles safe to run multiple times

## Role Convention
- Each role in `roles/<name>/` follows standard Ansible structure
- Tag name matches role name for selective execution
- Registered variables use role prefix (e.g., `font_*`, `desktop_*`)
- Role defaults in `roles/<name>/defaults/main.yml`

## Code Standards
- **Naming**: Use role prefix for all registered variables
- **License**: `SPDX-License-Identifier: MIT-0` in all new files
- **Linting**: Always run `ansible-lint --profile production --fix` before commit

## Progressive Disclosure
Role-specific details, architecture diagrams, and extended documentation are in:
- **ARCHITECTURE.md** - System architecture, component details, deployment
- **roles/*/README.md** - Role-specific documentation
- **roles/*/defaults/main.yml** - Role variables and feature toggles

Read these files when working on specific roles for detailed context.
