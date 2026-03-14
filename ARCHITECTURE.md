# SPDX-License-Identifier: MIT-0
# =============================================================================
# Architecture Overview - Ansible Fedora Workstation Configuration
# =============================================================================
# This document provides a comprehensive understanding of the codebase's
# architecture, enabling efficient navigation and effective contribution.
# =============================================================================

## 1. Project Structure

This Ansible-based project transforms a fresh Fedora installation into a fully
configured development environment. The architecture follows ansible-creator
best practices with collection-based organization and role-based modularity.

```
[Project Root]/
├── site.yml                   # Main entry point (ansible-creator standard)
├── playbook.yaml              # Main playbook configuration
├── inventory/
│   ├── hosts                 # Inventory file
│   └── group_vars/
│       └── all.yml           # Group variables
├── requirements.yml           # Ansible collection dependencies
├── ansible.cfg                # Ansible configuration
├── ansible-navigator.yml      # Ansible Navigator configuration
├── init.sh                    # Bootstrap script
├── ci_vars.yml                # CI-specific variables for testing
│
├── collections/
│   └── ansible_collections/
│       └── local/
│           └── workstation/   # Local collection
│               ├── galaxy.yml # Collection metadata
│               ├── README.md
│               ├── .gitignore
│               ├── meta/
│               │   └── runtime.yml
│               └── roles/
│                   ├── common/
│                   │   ├── tasks/
│                   │   ├── defaults/
│                   │   ├── handlers/
│                   │   ├── files/
│                   │   ├── templates/
│                   │   └── meta/
│                   ├── locale/
│                   ├── git/
│                   ├── stability/
│                   ├── developer/
│                   ├── font/
│                   ├── power/
│                   └── multimedia/
│
├── .github/
│   └── workflows/
│       └── tests.yml          # CI/CD pipeline
│
├── .devcontainer/
│   └── devcontainer.json      # DevContainer configuration
│
├── .pre-commit-config.yaml    # Pre-commit hooks
├── .yamllint                  # YAML lint configuration
├── .gitignore
├── CLAUDE.md
├── README.md
└── ARCHITECTURE.md
```

## 2. High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Fedora Workstation (Target)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐     ┌─────────────────────────────────────────────┐   │
│  │   init.sh       │────▶│  Ansible Core (ansible-playbook)            │   │
│  │  (Bootstrap)    │     │  - Reads site.yml                           │   │
│  └─────────────────┘     │  - Loads inventory/hosts                     │   │
│                          │  - Executes collection roles                 │   │
│                          └─────────────────────────────────────────────┘   │
│                                                   │                         │
│                                                   ▼                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              local.workstation Collection (Roles)                   │   │
│  ├─────────────┬─────────────┬─────────────┬─────────────┬─────────────┤   │
│  │   common    │   locale    │   git       │  stability  │  developer  │   │
│  │  (dnf5/rpm) │ (en_US/xdg) │ (ssh-sign)  │ (snapshot)  │ (sdk/tools) │   │
│  ├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤   │
│  │    font     │    power    │ multimedia  │   embed     │             │   │
│  │ (ttf/otf)   │  (tlp)      │  (codecs)   │  (stm32)    │             │   │
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
│  │ Ansible Lint │  │ YAML Lint    │  │  Fedora Test                     │  │
│  │ (Production) │  │ (Syntax)     │  │  - Syntax check                  │  │
│  └──────────────┘  └──────────────┘  │  - Check mode                    │  │
│                                       └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 3. Core Components

### 3.1. Entry Points

#### 3.1.1. site.yml (Main Entry Point)

**Description:** Primary entry point following ansible-creator standards.
Imports the main playbook configuration.

**Technologies:** Ansible Playbook YAML

**Key Features:**
- Standard entry point for ansible-navigator
- Compatible with ansible-playbook command

#### 3.1.2. playbook.yaml (Main Configuration)

**Description:** Main orchestrator that executes all roles from the local.workstation collection.
Each role is tagged with its name for selective execution.

**Technologies:** Ansible Playbook YAML

**Key Features:**
- Uses fully qualified collection names (FQCN) for roles
- Supports variable overrides via `-e` flag
- Includes pre and post tasks for status display

#### 3.1.3. init.sh (Bootstrap Script)

**Description:** Entry point for provisioning. Handles Ansible installation if missing,
then executes the main playbook.

**Technologies:** Bash, DNF5, Python venv

**Key Features:**
- Detects and installs Ansible via pip
- Creates Python virtual environment
- Passes through all arguments to `ansible-playbook`

### 3.2. Ansible Collection

#### 3.2.1. local.workstation Collection

**Description:** Local collection containing all workstation automation roles.
Organized following ansible-creator collection standards.

**Structure:**
- `galaxy.yml` - Collection metadata and dependencies
- `meta/runtime.yml` - Minimum Ansible version requirements
- `roles/` - All role directories with standard structure

**Collection Roles:**

##### 3.2.1.1. common (Base System Configuration)

**Description:** Foundation tasks required for all subsequent roles. Handles package
manager configuration, third-party repositories, and system updates.

**Key Tasks:**
- RPM Fusion repository enablement (free + non-free)
- DNF5 configuration and optimization
- System firmware and driver updates
- NVIDIA driver installation (optional)

**Variables:** `common_enable_rpm_fusion`, `common_install_nvidia_drivers`, `common_configure_custom_dns`, `common_install_d2`

##### 3.2.1.2. locale (English-Only Environment)

**Description:** Enforces strict English-only environment across system locale, XDG
directories, and input methods. Critical for consistent log output and debugging.

**Task Files:**
- `system_locale.yml` - Configures `/etc/locale.conf`, `/etc/environment`
- `xdg_dirs.yml` - Migrates localized XDG directories to English
- `input_method.yml` - Configures ibus/fcitx5 for English input
- `cli_language.yml` - Enforces locale in shell profiles

**Variables:** `locale_lang`, `locale_input_method`, `locale_remove_secondary_layouts`

**Feature Toggles:**
- `locale_configure_system_locale`
- `locale_configure_xdg_dirs`
- `locale_configure_input_method`
- `locale_enforce_cli_language`

##### 3.2.1.3. git (Version Control Configuration)

**Description:** Configures Git with user settings, commit signing (SSH keys),
and sensible defaults for development workflows.

**Key Tasks:**
- User identity configuration
- SSH key signing for commits
- Default branch and init settings

##### 3.2.1.4. stability (Fedora Stability & Hardening)

**Description:** Implements Fedora stability features and system hardening.

**Key Tasks:**
- Btrfs snapshot configuration (snapper)
- Firewall configuration (firewalld)
- Automatic updates (dnf-automatic)

##### 3.2.1.5. developer (Development Tools & Runtimes)

**Description:** Provisions complete development environment including compilers,
package managers, language runtimes, and mobile development SDKs.

**Key Installations:**
- Compilers: GCC, Clang, Rust (via rustup)
- JavaScript: Bun package manager
- Python: uv (modern Python installer)
- Mobile: Flutter SDK, Android SDK (command-line tools only)

**Variables:** Role variables for SDK versions and installation paths

##### 3.2.1.6. font (Programming Fonts)

**Description:** Installs programming fonts from COPR repositories and local
font files for development and multilingual support.

**COPR Fonts:** JetBrains Mono, Fira Code, Inter, Arimo, IBM Plex Sans Thai

**Local Fonts:** Arial, Courier, THSarabunNew, Verdana

**Variables:** `font_install_enabled`, `font_sarabun_install_enabled`

##### 3.2.1.7. power (TLP Power Management)

**Description:** Installs and configures TLP for advanced power management and battery optimization.
Disabled by default (`power_install_tlp: false`).

**Key Tasks:**
- Disables and masks `power-profiles-daemon`
- Installs TLP packages: `tlp`, `tlp-pd`, `tlp-rdw`
- Configures SELinux boolean `tlp_can_write_to_d` for Fedora 38+ compatibility
- Deploys optimized `/etc/tlp.conf` with battery charge thresholds

**Variables:** `power_install_tlp`, `power_cpu_scaling_governor_on_ac`, `power_start_charge_thresh_bat0`, `power_stop_charge_thresh_bat0`

**Feature Toggles:**
- `power_install_tlp` - Main enable/disable toggle

##### 3.2.1.8. multimedia (Codecs & Hardware Acceleration)

**Description:** Installs multimedia codecs, FFmpeg, and enables hardware-accelerated
video decoding for smooth media playback.

**Key Tasks:** Codec installation, GPU acceleration setup

### 3.3. CI/CD Pipeline

**Description:** GitHub Actions workflow that validates playbook changes on every
push and pull request.

**Stages:**
1. **Lint:** Ansible Lint (production profile), YAML validation
2. **Syntax:** Playbook syntax check
3. **Test:** Check mode execution

**Technologies:** GitHub Actions, Fedora containers, Ansible Lint

**Key Validations:**
- Syntax: Valid YAML, compliant with Ansible production profile
- Check mode: Playbook must execute without errors in dry-run mode

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
| COPR (neurowelfare) | Custom programming fonts | DNF repository |
| GitHub Actions | CI/CD pipeline | Workflow YAML |

## 6. Deployment & Infrastructure

**Target Platform:** Fedora Workstation (Fedora 41+)

**Package Manager:** DNF5 (next-gen DNF)

**CI/CD Platform:** GitHub Actions (ubuntu-24.04 runners, Fedora containers)

**Monitoring & Logging:**
- CI logs uploaded as artifacts (retention: 14 days)
- Local execution logs: `ansible-run.log`, `idempotence.log`

**Key Infrastructure Tools:**
- Ansible Core 2.15+
- Python 3.12+ (via `python3` package)
- Ansible Lint (production profile)

## 7. Security Considerations

**Authentication:** N/A (local provisioning, uses sudo for privilege escalation)

**Authorization:** sudo privileges required for system-level changes

**Secrets Management:**
- No secrets in repository
- Sensitive data (SSH keys, GPG keys) managed by user locally

**Security Tools:**
- **Ansible Lint:** Security-focused rule checking
- **Pre-commit hooks:** Automated code quality checks

## 8. Development & Testing Environment

**Local Setup Instructions:**
```bash
# Clone repository
git clone <repo-url>
cd ansible-config

# Install collection dependencies
ansible-galaxy collection install -r requirements.yml

# Run complete provisioning
./init.sh

# Run specific roles only
ansible-playbook site.yml -i inventory/hosts --tags developer,font

# Lint the project
ansible-lint --profile production
```

**Testing Frameworks:**
- Ansible Lint (syntax and best practices)
- YAML validation via yamllint
- Pre-commit hooks for automated checks

**Code Quality Tools:**
- Ansible Lint with production profile
- YAML validation
- Shell script linting (shellcheck)

**CI Testing Strategy:**
1. Lint all roles for syntax and best practices
2. Run playbook syntax check
3. Execute playbook in check mode to verify idempotence

## 9. Future Considerations / Roadmap

**Current Known Limitations:**
- Local font files may bloat Git repository (consider Git LFS)
- Limited to Fedora Workstation (not portable to other distributions)

**Planned Improvements:**
- [ ] Migrate font files to Git LFS
- [ ] Add support for Fedora Server edition
- [ ] Implement hardware detection for conditional driver installation
- [ ] Create rollback mechanism for failed configurations

## 10. Project Identification

**Project Name:** Ansible Fedora Workstation Configuration

**Repository URL:** https://github.com/parinya-ao/ansible-config

**Target OS:** Fedora Workstation 41+

**Collection:** local.workstation

**Date of Last Update:** 2026-03-14

## 11. Glossary / Acronyms

| **Term** | **Definition** |
|----------|----------------|
| **Ansible** | Open-source automation tool for configuration management |
| **DNF5** | Next-generation Dandified YUM (package manager for Fedora) |
| **RPM Fusion** | Third-party software repository for Fedora |
| **COPR** | Community extras for RPM packages (build system for Fedora) |
| **XDG** | freedesktop.org specifications for directory structure |
| **Idempotence** | Property where applying an operation multiple times has the same effect as once |
| **Role** | Ansible unit of organization containing tasks, variables, handlers |
| **Playbook** | Ansible orchestration file that defines roles and execution order |
| **Collection** | Ansible distribution format for roles, plugins, and modules |
| **FQCN** | Fully Qualified Collection Name (e.g., local.workstation.common) |
| **Rustup** | Rust toolchain installer and version manager |
| **uv** | Modern Python package installer and project manager |
| **Bun** | JavaScript runtime and package manager |
