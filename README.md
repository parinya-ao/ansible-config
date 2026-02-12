# Ansible Fedora Workstation Configuration

> Automated Fedora Workstation provisioning using Ansible. Transform a fresh Fedora installation into a fully configured development environment with consistent tooling, desktop applications, and development runtimes.

![Fedora](https://img.shields.io/badge/Fedora-Latest-blue?logo=fedora&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-2.13+-red?logo=ansible)
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

This playbook automates the setup of a Fedora workstation for development work. It installs and configures:

- System optimizations and core utilities
- Development tools and runtimes
- Desktop applications and GNOME settings
- Fonts including Thai language support
- Docker and container tools
- Multimedia codecs and hardware acceleration

**Target OS**: Fedora Linux (tested on Fedora 41+)
**Execution**: Local provisioning via `ansible_connection=local`

## What It Covers

| Role | Description |
|-------|-------------|
| **common** | DNF optimization, RPM Fusion, system updates, firmware, core packages |
| **desktop** | Flatpak apps, GNOME extensions, Starship prompt, Ghostty terminal, Flatpak font access |
| **developer** | Compilers, Rust, Go, Node.js, Bun, Python (uv), Flutter, Android SDK |
| **docker** | Docker CE, Docker Compose, user group management |
| **git** | Git configuration with SSH key signing |
| **font** | JetBrains Mono, Fira Code, Inter, Sarabun (Thai) |
| **wifi** | Wi-Fi performance optimization |
| **multimedia** | Codecs, FFmpeg, hardware video acceleration |

## Prerequisites

- Fedora Linux (40+ recommended)
- `sudo` privileges for system-level changes
- Ansible 2.13+ (or use `./init.sh` to bootstrap)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ansible-config.git
cd ansible-config

# Run the complete playbook
ansible-playbook playbook.yaml -i inventory.ini

# Run specific roles only (by tag)
ansible-playbook playbook.yaml -i inventory.ini --tags font,desktop

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
├── playbook.yaml          # Main entry point - runs all roles
├── inventory.ini          # Localhost inventory
├── requirements.yml       # Ansible collection dependencies
├── init.sh                # Bootstrap script
├── roles/
│   ├── common/           # Base system configuration
│   ├── desktop/          # GUI apps and settings
│   ├── developer/        # Development tools
│   ├── docker/           # Docker CE
│   ├── git/              # Git configuration
│   ├── font/             # Programming fonts
│   ├── wifi/             # Wi-Fi optimization
│   └── multimedia/       # Codecs and video acceleration
├── .github/workflows/    # CI/CD pipelines
└── .ansible/lint         # Lint configuration
```

## Customization

### Role Variables

Each role has configurable defaults in `roles/<name>/defaults/main.yml`:

```yaml
# Example: font role defaults
font_sarabun_install_enabled: true    # Install Sarabun Thai font
font_install_enabled: true               # Main font toggle

# Example: desktop role defaults
desktop_enable_flatpak_font_access: true  # Fix Flatpak font rendering
desktop_install_ghostty: true             # Install Ghostty terminal
```

### Feature Toggles

Override variables via command line:

```bash
# Disable specific feature
ansible-playbook playbook.yaml -i inventory.ini -e "desktop_install_ghostty=false"
```

### Adding Custom Fonts

1. Place font files in `roles/font/file/<YourFont>/`
2. Run the font role: `ansible-playbook playbook.yaml -i inventory.ini --tags font`

## Development

### Code Standards

- **Naming**: Registered variables MUST use role prefix (e.g., `font_*`, `desktop_*`)
- **License**: Use `SPDX-License-Identifier: MIT-0` in all new files
- **Structure**: Follow standard Ansible role layout (`tasks/`, `defaults/`, `handlers/`, etc.)

### Linting

```bash
# Lint with auto-fix
ansible-lint --profile production --fix roles/

# Lint entire project
ansible-lint --profile production
```

### Running Specific Roles

```bash
# Run only font configuration
ansible-playbook playbook.yaml -i inventory.ini --tags font

# Run desktop setup only
ansible-playbook playbook.yaml -i inventory.ini --tags desktop
```

## Testing & CI

### Local Testing

```bash
# Syntax check
ansible-playbook playbook.yaml --syntax-check

# Check mode (dry run)
ansible-playbook playbook.yaml -i inventory.ini --check

# List tags
ansible-playbook playbook.yaml --list-tags
```

### CI/CD Pipeline

The `.github/workflows/ci.yml` workflow runs on:
- Push to `main`/`develop` branches
- Pull requests

It performs:
1. `ansible-lint` with production profile
2. YAML syntax validation
3. Fedora container tests with idempotence checks

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow code standards (see [Development](#development))
4. Run linting: `ansible-lint --profile production --fix roles/`
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
<summary>How do I fix Flatpak font rendering (Discord, Obsidian)?</summary>

The playbook automatically configures Flatpak to access system fonts. If you still have issues:

```bash
# Re-run the desktop role
ansible-playbook playbook.yaml -i inventory.ini --tags desktop
```
</details>

<details>
<summary>Can I run this on other Linux distributions?</summary>

This playbook is designed for **Fedora only**. It uses DNF, Fedora-specific COPR repositories, and assumes systemd. Adapting to other distros would require significant changes.
</details>

<details>
<summary>How do I add a new role?</summary>

1. Create directory: `mkdir -p roles/your-role/{tasks,defaults,handlers}`
2. Add `tasks/main.yml` with your tasks
3. Add `defaults/main.yml` with variables (use role prefix: `yourrole_*`)
4. Import in `playbook.yaml`
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
- Font authors: JetBrains Mono, Fira Code, Inter, and Sarabun
