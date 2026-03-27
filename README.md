# Ansible Fedora Workstation Configuration

> Automated Fedora Workstation provisioning using Ansible. Transform a fresh Fedora installation into a fully configured development environment with consistent tooling, desktop applications, and development runtimes.

![Fedora](https://img.shields.io/badge/Fedora-Latest-blue?logo=fedora&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-2.15+-red?logo=ansible)
![License](https://img.shields.io/badge/License-MIT--0-green)

## Table of Contents

- [Overview](#overview)
- [What It Covers](#what-it-covers)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Customization](#customization)
- [Development](#development)
- [Testing & CI](#testing--ci)
- [Contributing](#contributing)
- [License](#license)

## Overview

This playbook automates the setup of a Fedora/Ultramarine workstation for development work. It installs and configures:

- System optimizations and core utilities
- Development tools and runtimes
- Desktop applications and settings
- Multimedia codecs and hardware acceleration

**Target OS**: Fedora Linux / Ultramarine Linux (tested on Fedora 41+)
**Execution**: Local provisioning via `ansible_connection=local`

**Note**: Ultramarine Linux includes Podman (container management) pre-installed by default.

## What It Covers

| Role | Description |
|-------|-------------|
| **common** | DNF optimization, RPM Fusion, system updates, firmware, core packages |
| **locale** | English-only environment enforcement |
| **git** | Git configuration with SSH key signing |
| **stability** | Fedora stability and hardening |
| **developer** | Compilers, Rust, Go, Node.js, Bun, Python (uv), Flutter, Android SDK |
| **multimedia** | Codecs, FFmpeg, hardware video acceleration |

## Prerequisites

- Fedora Linux (40+ recommended)
- `sudo` privileges for system-level changes
- Ansible 2.15+ (or use `./init.sh` to bootstrap)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ansible-config.git
cd ansible-config

# Install collection dependencies
ansible-galaxy collection install -r requirements.yml

# Run the complete playbook
ansible-playbook site.yml -i inventory/hosts

# Run specific roles only (by tag)
ansible-playbook site.yml -i inventory/hosts --tags developer

# Use init script (installs Ansible if missing)
./init.sh
```

### Bootstrap Script

The `init.sh` script handles:
1. Installing Ansible if not present
2. Installing required collections
3. Running the main playbook

## Project Structure

```
ansible-config/
├── site.yml                 # Main entry point (ansible-creator standard)
├── playbook.yaml            # Main playbook configuration
├── inventory/
│   ├── hosts               # Inventory file
│   └── group_vars/
│       └── all.yml         # Group variables
├── requirements.yml         # Ansible collection dependencies
├── ansible.cfg              # Ansible configuration
├── ansible-navigator.yml    # Ansible Navigator configuration
├── init.sh                  # Bootstrap script
├── collections/
│   └── ansible_collections/
│       └── local/
│           └── workstation/    # Local collection
│               ├── galaxy.yml  # Collection metadata
│               ├── README.md
│               ├── meta/
│               │   └── runtime.yml
│               └── roles/
│                   ├── common/
│                   ├── locale/
│                   ├── git/
│                   ├── stability/
│                   ├── developer/
│                   ├── power/
│                   └── multimedia/
├── .github/workflows/      # CI/CD pipelines
├── .devcontainer/          # DevContainer configuration
└── .pre-commit-config.yaml # Pre-commit hooks
```

## Customization

### Role Variables

Each role has configurable defaults in `collections/ansible_collections/local/workstation/roles/<name>/defaults/main.yml`:

```yaml
# Example: developer role defaults
developer_install_flutter: false      # Install Flutter SDK
developer_install_nodejs: true        # Install Node.js
```

### Feature Toggles

Override variables via command line:

```bash
# Disable specific feature
ansible-playbook site.yml -i inventory/hosts -e "developer_install_flutter=false"
```

## Development

### Code Standards

- **Naming**: Registered variables MUST use role prefix (e.g., `common_*`, `developer_*`, `locale_*`)
- **License**: Use `SPDX-License-Identifier: MIT-0` in all new files
- **Structure**: Follow standard Ansible role layout (`tasks/`, `defaults/`, `handlers/`, etc.)

### Linting

```bash
# Lint with auto-fix
ansible-lint --profile production --fix

# Lint entire project
ansible-lint --profile production
```

### Running Specific Roles

```bash
# Run developer setup only
ansible-playbook site.yml -i inventory/hosts --tags developer

# Run multimedia codec installation
ansible-playbook site.yml -i inventory/hosts --tags multimedia
```

## Testing & CI

### Local Testing

```bash
# Syntax check
ansible-playbook site.yml --syntax-check

# Check mode (dry run)
ansible-playbook site.yml -i inventory/hosts --check

# List tags
ansible-playbook site.yml --list-tags
```

### CI/CD Pipeline

The `.github/workflows/tests.yml` workflow runs on:
- Push to `main`/`develop` branches
- Pull requests

It performs:
1. `ansible-lint` with production profile
2. YAML syntax validation
3. Playbook syntax check and dry run

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow code standards (see [Development](#development))
4. Run linting: `ansible-lint --profile production`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Testing Your Changes

Before submitting a PR:
- Run the full playbook or test your specific role
- Ensure `ansible-lint` passes with production profile
- Test on a fresh Fedora VM if possible

## FAQ

<details>
<summary>Can I run this on other Linux distributions?</summary>

This playbook is designed for **Fedora and Ultramarine**. It uses DNF, Fedora/Ultramarine-specific COPR repositories, and assumes systemd. Adapting to other distros would require significant changes.
</details>

<details>
<summary>How do I add a new role?</summary>

1. Create directory: `mkdir -p collections/ansible_collections/local/workstation/roles/your-role/{tasks,defaults,handlers}`
2. Add `tasks/main.yml` with your tasks
3. Add `defaults/main.yml` with variables (use role prefix: `yourrole_*`)
4. Update `playbook.yaml` to include the new role
</details>

## Project Status

- **Active**: Maintained regularly with updates for new Fedora releases
- **CI**: Production lint profile enforced, all tests must pass
- **Dependencies**: Uses official COPR repos and Flathub

## License

MIT-0. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [Ansible](https://www.ansible.com/) - Configuration management
- [Fedora](https://fedoraproject.org/) - The base distribution
- [Flathub](https://flathub.org/) - Flatpak application repository
- Font authors: JetBrains Mono, Fira Code, Inter, Sarabun
