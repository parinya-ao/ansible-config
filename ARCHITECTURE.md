# SPDX-License-Identifier: MIT-0
# =============================================================================
# Architecture Overview - Ansible Fedora Workstation Configuration
# =============================================================================
# This document provides a comprehensive understanding of the codebase's
# architecture, enabling efficient navigation and effective contribution.
# =============================================================================

## 1. Project Structure

This Ansible-based project transforms a fresh Fedora installation into a fully
configured development environment. The architecture follows Ansible best
practices with role-based modularity and idempotent operations.

```
[Project Root]/
├── playbook.yaml              # Main entry point - runs all roles
├── inventory.ini              # Localhost inventory file
├── requirements.yml           # Ansible collection dependencies
├── init.sh                    # Bootstrap script (installs Ansible + runs playbook)
├── ci_vars.yml                # CI-specific variables for testing
│
├── roles/                     # All Ansible roles (modular tasks)
│   ├── common/                # Base system: DNF, RPM Fusion, updates, firmware
│   │   ├── tasks/             # Task files
│   │   ├── defaults/          # Role variables with defaults
│   │   ├── handlers/          # Event handlers (restart services, etc.)
│   │   ├── files/             # Static files to copy
│   │   ├── templates/         # Jinja2 templates
│   │   └── meta/              # Role metadata and dependencies
│   ├── locale/                # English-only environment enforcement
│   │   ├── tasks/             # system_locale.yml, xdg_dirs.yml, input_method.yml, cli_language.yml
│   │   └── defaults/          # Locale configuration variables
│   ├── desktop/               # GUI apps: GNOME, Flatpak, Ghostty, Starship
│   ├── developer/             # Dev tools: compilers, Bun, Python (uv), Flutter, Android
│   ├── docker/                # Docker CE installation and configuration
│   ├── git/                   # Git configuration with SSH key signing
│   ├── font/                  # Programming fonts (JetBrains Mono, Fira Code, Inter, Sarabun)
│   ├── wifi/                  # Wi-Fi performance optimization
│   └── multimedia/            # Codecs, FFmpeg, hardware video acceleration
│
├── .github/                   # GitHub Actions CI/CD
│   └── workflows/
│       └── ci.yml             # Security scan, lint, idempotence test on Fedora
│
├── .ansible/                  # Ansible runtime configuration
│   └── lint/                  # Ansible lint configuration
│
├── .gitignore                 # Specifies intentionally untracked files
├── CLAUDE.md                  # Project instructions for AI agents
├── README.md                  # Project overview and quick start guide
└── ARCHITECTURE.md            # This document
```

## 2. High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Fedora Workstation (Target)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐     ┌─────────────────────────────────────────────┐   │
│  │   init.sh       │────▶│  Ansible Core (ansible-playbook)            │   │
│  │  (Bootstrap)    │     │  - Reads playbook.yaml                      │   │
│  └─────────────────┘     │  - Loads inventory.ini                       │   │
│                          │  - Executes roles sequentially               │   │
│                          └─────────────────────────────────────────────┘   │
│                                                   │                         │
│                                                   ▼                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Roles (Modular Tasks)                        │   │
│  ├─────────────┬─────────────┬─────────────┬─────────────┬─────────────┤   │
│  │   common    │   locale    │   desktop   │  developer  │    docker   │   │
│  │  (dnf5/rpm) │ (en_US/xdg) │ (flatpak)   │  (sdk/tools)│ (container) │   │
│  ├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤   │
│  │     git     │    font     │    wifi     │ multimedia  │             │   │
│  │  (ssh-sign) │ (ttf/otf)   │  (tweak)    │  (codecs)   │             │   │
│  └─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘   │
│                          │                                                 │
│                          ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     System Changes (Idempotent)                     │   │
│  │  - Package installation (DNF5)                                      │   │
│  │  - Configuration file management                                   │   │
│  │  - Service enablement/startup (systemd)                            │   │
│  │  - User environment customization                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         GitHub Actions (CI/CD)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────────────┐  │
│  │ TruffleHog   │  │ Ansible Lint │  │  Fedora Container Test           │  │
│  │ (Secrets)    │  │ (Syntax)     │  │  - Security scanning (Checkov)   │  │
│  └──────────────┘  └──────────────┘  │  - Idempotence verification      │  │
│                                       │  - Post-run validation          │  │
│                                       └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 3. Core Components

### 3.1. Entry Points

#### 3.1.1. init.sh (Bootstrap Script)

**Description:** Entry point for provisioning. Handles Ansible installation if missing,
then executes the main playbook. Supports CI mode with `--skip-install` flag.

**Technologies:** Bash, DNF5, Python venv

**Key Features:**
- Detects and installs Ansible via pip
- Creates Python virtual environment at `.ansible-venv/`
- Passes through all arguments to `ansible-playbook`

#### 3.1.2. playbook.yaml

**Description:** Main orchestrator that imports and executes all roles in sequence.
Each role is tagged with its name for selective execution.

**Technologies:** Ansible Playbook YAML

**Key Features:**
- Uses role tags for granular execution
- Imports all roles from `roles/` directory
- Supports variable overrides via `-e` flag

### 3.2. Ansible Roles

#### 3.2.1. common (Base System Configuration)

**Description:** Foundation tasks required for all subsequent roles. Handles package
manager configuration, third-party repositories, and system updates.

**Key Tasks:**
- RPM Fusion repository enablement (free + non-free)
- DNF5 configuration and optimization
- System firmware and driver updates
- NVIDIA driver installation (optional, via `common_install_nvidia_drivers`)

**Variables:** `common_enable_rpm_fusion`, `common_install_nvidia_drivers`, `common_configure_custom_dns`, `common_install_d2`

#### 3.2.2. locale (English-Only Environment)

**Description:** Enforces strict English-only environment across system locale, XDG
directories, input methods, and CLI output. Critical for consistent log output
and debugging.

**Task Files:**
- `system_locale.yml` - Configures `/etc/locale.conf`, `/etc/environment`
- `xdg_dirs.yml` - Migrates localized XDG directories to English
- `input_method.yml` - Configures ibus/fcitx5 for English input
- `cli_language.yml` - Enforces locale in shell profiles

**Variables:** `locale_lang`, `locale_input_method`, `locale_remove_secondary_layouts`, `locale_secondary_layouts`

**Feature Toggles:**
- `locale_configure_system_locale`
- `locale_configure_xdg_dirs`
- `locale_configure_input_method`
- `locale_enforce_cli_language`

#### 3.2.3. desktop (Desktop Environment & GUI Apps)

**Description:** Installs and configures desktop applications, terminal emulators,
and shell enhancements for GNOME desktop environment.

**Key Tasks:**
- GNOME Shell extensions and tweaks
- Flatpak runtime configuration
- Ghostty terminal emulator
- Starship prompt for bash/zsh

**Variables:** `desktop_enable_flatpak_font_access`

#### 3.2.4. developer (Development Tools & Runtimes)

**Description:** Provisions complete development environment including compilers,
package managers, language runtimes, and mobile development SDKs.

**Key Installations:**
- Compilers: GCC, Clang, Rust (via rustup)
- JavaScript: Bun package manager
- Python: uv (modern Python installer)
- Mobile: Flutter SDK, Android SDK (command-line tools only)

**Variables:** Role variables for SDK versions and installation paths

#### 3.2.5. docker (Container Runtime)

**Description:** Installs Docker CE from official Docker repository, configures
daemon settings, and adds user to docker group.

**Key Tasks:**
- Docker repository setup
- Package installation and daemon configuration
- User permissions (docker group)
- Daemon start and enable

#### 3.2.6. git (Version Control Configuration)

**Description:** Configures Git with user settings, commit signing (SSH keys),
and sensible defaults for development workflows.

**Key Tasks:**
- User identity configuration
- SSH key signing for commits
- Default branch and init settings

#### 3.2.7. font (Programming Fonts)

**Description:** Installs programming fonts from COPR repositories and local
font files for development and multilingual support.

**COPR Fonts:** JetBrains Mono, Fira Code, Inter, Arimo, IBM Plex Sans Thai

**Local Fonts:** Arial, Courier, THSarabunNew, Verdana

**Variables:** `font_install_enabled`, `font_sarabun_install_enabled`

> **Note:** Local font files in `roles/font/files/` are binary assets.
> Consider using Git LFS to manage these files.

#### 3.2.8. wifi (Wi-Fi Optimization)

**Description:** Optimizes Wi-Fi performance and connectivity for Fedora workstations.

**Key Tasks:** NetworkManager and wireless driver configuration

#### 3.2.9. multimedia (Codecs & Hardware Acceleration)

**Description:** Installs multimedia codecs, FFmpeg, and enables hardware-accelerated
video decoding for smooth media playback.

**Key Tasks:** Codec installation, GPU acceleration setup

### 3.3. CI/CD Pipeline

**Description:** GitHub Actions workflow that validates playbook changes on every
push and pull request.

**Stages:**
1. **Security Scan:** TruffleHog (secrets), Checkov (IaC security)
2. **Lint & Syntax:** Actionlint (workflow), Ansible Lint (playbook)
3. **Integration Test:** Fedora container with idempotence verification

**Technologies:** GitHub Actions, Fedora containers, Ansible Lint, Checkov, TruffleHog

**Key Validations:**
- Idempotence: Playbook must not change state on second run (tolerance: ≤5 changes)
- Security: No secrets in code, no IaC misconfigurations
- Syntax: Valid YAML, compliant with Ansible production profile

## 4. Data Stores

This project does not use traditional databases. Configuration state is stored in:

| **Location** | **Type** | **Purpose** |
|--------------|----------|-------------|
| `/etc/locale.conf` | Text file | System locale configuration |
| `/etc/environment` | Text file | Environment variables |
| `~/.config/` | Directory tree | User configuration files |
| `~/.local/share/` | Directory tree | XDG data directories |
| `/etc/dnf/dnf5.conf` | DNF5 config | Package manager settings |
| `/etc/systemd/` | Directory tree | Service unit files |

## 5. External Integrations / APIs

| **Service** | **Purpose** | **Integration Method** |
|-------------|-------------|------------------------|
| Fedora Packages (DNF) | Package installation | DNF5 API / dnf5 command |
| RPM Fusion | Third-party RPM packages | Repository subscription |
| Flathub | Flatpak applications | Flatpak remote configuration |
| COPR (neurowelfare) | Custom programming fonts | DNF repository |
| Docker Hub | Container images | Docker daemon |
| GitHub Actions | CI/CD pipeline | Workflow YAML |

## 6. Deployment & Infrastructure

**Target Platform:** Fedora Workstation (Fedora 41+)

**Package Manager:** DNF5 (next-gen DNF)

**CI/CD Platform:** GitHub Actions (ubuntu-24.04 runners, Fedora containers)

**Container Runtime:** Docker (for CI testing)

**Monitoring & Logging:**
- CI logs uploaded as artifacts (retention: 14 days)
- Local execution logs: `ansible_run.log`, `idempotence.log`

**Key Infrastructure Tools:**
- Ansible Core 2.18+
- Python 3.13+ (via `python3` package)
- Ansible Lint (production profile)
- Checkov (IaC security scanning)

## 7. Security Considerations

**Authentication:** N/A (local provisioning, uses sudo for privilege escalation)

**Authorization:** sudo privileges required for system-level changes

**Secrets Management:**
- No secrets in repository (enforced by TruffleHog scanning)
- Sensitive data (SSH keys, GPG keys) managed by user locally

**Security Tools:**
- **TruffleHog:** Secret detection in commits
- **Checkov:** Infrastructure-as-Code security scanning
- **Ansible Lint:** Security-focused rule checking

**Supply Chain Security:**
- RPM Fusion GPG key verification (with Checkov suppressions for false positives)
- Package integrity via DNF5's built-in GPG verification

## 8. Development & Testing Environment

**Local Setup Instructions:**
```bash
# Clone repository
git clone <repo-url>
cd ansible-config

# Run complete provisioning
./init.sh

# Run specific roles only
ansible-playbook playbook.yaml -i inventory.ini --tags desktop,docker

# Lint the project
ansible-lint --profile production --fix roles/
```

**Testing Frameworks:**
- Ansible Lint (syntax and best practices)
- Idempotence verification (custom bash script in CI)
- TruffleHog (secret scanning)
- Checkov (security policy scanning)

**Code Quality Tools:**
- Ansible Lint with production profile
- YAML validation via Actionlint
- Shell script linting (optional)

**CI Testing Strategy:**
1. Lint all roles for syntax and best practices
2. Run playbook in Fedora container with reduced features
3. Execute playbook twice to verify idempotence
4. Verify critical services and configurations

## 9. Future Considerations / Roadmap

**Current Known Limitations:**
- Local font files bloat Git repository (consider Git LFS)
- Idempotence tolerance of 5 changed tasks masks some non-idempotent behaviors
- Limited to Fedora Workstation (not portable to other distributions)

**Planned Improvements:**
- [ ] Migrate font files to Git LFS
- [ ] Add support for Fedora Server edition
- [ ] Implement role dependency graph visualization
- [ ] Add hardware detection for conditional driver installation
- [ ] Create rollback mechanism for failed configurations

**Architectural Debt:**
- Some roles have interdependencies not explicitly declared in `meta/dependencies.yml`
- CI test bypasses some features (RPM Fusion, NVIDIA) for container compatibility

## 10. Project Identification

**Project Name:** Ansible Fedora Workstation Configuration

**Repository URL:** https://github.com/parinya-ao/ansible-config

**Target OS:** Fedora Workstation 41+

**Primary Contact:** parinya-ao

**Date of Last Update:** 2026-02-26

## 11. Glossary / Acronyms

| **Term** | **Definition** |
|----------|----------------|
| **Ansible** | Open-source automation tool for configuration management |
| **DNF5** | Next-generation Dandified YUM (package manager for Fedora) |
| **RPM Fusion** | Third-party software repository for Fedora (provides proprietary software) |
| **Flatpak** | Universal application packaging format for Linux |
| **COPR** | Community extras for RPM packages (build system for Fedora) |
| **XDG** | freedesktop.org specifications for directory structure and configuration |
| **Idempotence** | Property where applying an operation multiple times has the same effect as applying it once |
| **Role** | Ansible unit of organization containing tasks, variables, handlers, files, and templates |
| **Playbook** | Ansible orchestration file that defines roles and execution order |
| **GNOME** | Default desktop environment for Fedora Workstation |
| **Rustup** | Rust toolchain installer and version manager |
| **uv** | Modern Python package installer and project manager |
| **Bun** | JavaScript runtime and package manager |