# Ansible Fedora Workstation Configuration

Automated Fedora Workstation provisioning using Ansible. Transforms a fresh Fedora installation into a fully configured development environment.

## Project Structure

```
ansible-config/
├── playbook.yaml          # Main entry point
├── init.sh                # Bootstrap script (creates venv, installs Ansible, runs playbook)
├── inventory.ini          # Localhost inventory
├── requirements.yml       # Ansible collection dependencies
├── roles/                 # All Ansible roles (see below)
├── .github/workflows/     # CI: lint, security scan, idempotence test
└── .ansible/lint          # Ansible lint configuration
```

**Roles**: `common` | `locale` | `desktop` | `developer` | `docker` | `git` | `font` | `wifi` | `multimedia`

## Key Commands

```bash
./init.sh                                    # Bootstrap and run playbook
./init.sh -K                                 # Run with sudo password prompt
ansible-playbook playbook.yaml --tags docker # Run specific role
ansible-lint --profile production --fix      # Lint and auto-fix
```

## Development Conventions

- **Target OS**: Fedora only
- **Privilege escalation**: Requires `sudo` (use `-K` flag for password prompt)
- **Connection**: Local only (`ansible_connection=local`)
- **Role structure**: Standard Ansible (`tasks/`, `defaults/`, `handlers/`)
- **Naming**: Register variables with role prefix (e.g., `locale_*`, `docker_*`)
- **License header**: `SPDX-License-Identifier: MIT-0`
- **Idempotency**: All roles must be idempotent (verified in CI)

## Progressive Disclosure

For role-specific details, read these files when working on related tasks:

| Task | Read |
|------|------|
| Role variables/defaults | `roles/<name>/defaults/main.yml` |
| Role task logic | `roles/<name>/tasks/main.yml` |
| CI pipeline details | `.github/workflows/ci.yml` |
| Ansible configuration | `ansible.cfg` |
