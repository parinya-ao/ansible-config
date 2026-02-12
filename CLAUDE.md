# Ansible Fedora Workstation Configuration

## Purpose
Automated Fedora Workstation provisioning using Ansible. Transforms a fresh Fedora installation into a fully configured development environment with consistent tooling, desktop applications, and development runtimes.

## Project Structure

```
ansible-config/
├── playbook.yaml          # Main entry point - runs all roles
├── inventory.ini          # Localhost inventory
├── requirements.yml       # Ansible collection dependencies
├── init.sh                # Bootstrap script (installs Ansible + runs playbook)
├── roles/                 # All Ansible roles
│   ├── common/           # Base system: DNF, RPM Fusion, updates, firmware
│   ├── desktop/          # GUI apps: GNOME, Flatpak, Ghostty, Starship
│   ├── developer/        # Dev tools: compilers, Bun, Python (uv), Flutter, Android SDK
│   ├── docker/           # Docker CE installation and configuration
│   ├── git/              # Git configuration with SSH key signing
│   ├── font/             # Programming fonts (JetBrains Mono, Fira Code, Inter, Sarabun)
│   ├── wifi/             # Wi-Fi performance optimization
│   └── multimedia/       # Codecs, FFmpeg, hardware video acceleration
├── .github/workflows/    # CI/CD: security scan, lint, test on Fedora
└── .ansible/lint         # Ansible lint configuration
```

## Key Commands

```bash
# Run complete playbook
ansible-playbook playbook.yaml -i inventory.ini

# Run specific roles only (by tag)
ansible-playbook playbook.yaml -i inventory.ini --tags common,docker

# Use init script (installs Ansible if missing)
./init.sh

# Lint the project (auto-fix issues)
ansible-lint --profile production --fix roles/

# Lint entire project
ansible-lint --profile production
```

## Development Workflow

- **Roles**: Each role is in `roles/<name>/` with standard Ansible structure (`tasks/`, `defaults/`, `handlers/`, etc.)
- **Variables**: Role defaults in `roles/<name>/defaults/main.yml`
- **Tags**: Each role has a tag matching its name for selective execution
- **Testing**: Changes are tested via GitHub Actions on Fedora containers with idempotence checks

## Code Standards

- **Naming**: Registered variables in roles MUST use role prefix (e.g., `font_*` in font role, `desktop_*` in desktop role)
- **Linting**: Always run `ansible-lint --profile production --fix` before committing
- **License**: Use `SPDX-License-Identifier: MIT-0` in all new files

## Important Notes

- Target OS: **Fedora only**
- Requires `sudo` privileges for system-level changes
- Uses `ansible_connection=local` (no remote hosts)
- Feature toggles exist in role defaults (e.g., `font_sarabun_install_enabled`, `desktop_enable_flatpak_font_access`)
- All roles are idempotent - safe to run multiple times

## Documentation References

- Role-specific details: See each role's `README.md` or `defaults/main.yml`
- CI/CD pipeline: `.github/workflows/ci.yml`
- Ansible collection requirements: `requirements.yml`
