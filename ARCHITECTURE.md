# Architecture Overview

This document serves as a critical, living template designed to equip agents with a rapid and comprehensive understanding of the codebase's architecture, enabling efficient navigation and effective contribution from day one. Update this document as the codebase evolves.

**Last Updated**: 2026-03-15

## 1. Project Structure

This section provides a high-level overview of the project's directory and file structure, categorised by architectural layer or major functional area. It is essential for quickly navigating the codebase, locating relevant files, and understanding the overall organization and separation of concerns.

```
[Project Root]/
├── site.yml                    # Main entry point (ansible-creator standard)
├── playbook.yaml               # Main playbook configuration
├── inventory/
│   ├── hosts                   # Inventory file (localhost)
│   └── group_vars/
│       └── all.yml             # Group variables
├── ci_vars.yml                 # CI/CD pipeline variables
├── requirements.yml            # Ansible collection dependencies
├── ansible.cfg                 # Ansible configuration
├── ansible-navigator.yml       # Ansible Navigator configuration
├── init.sh                     # Bootstrap script for Fedora
├── main.py                     # (Unused - legacy)
├── collections/
│   └── ansible_collections/
│       └── local/
│           └── workstation/    # Local collection (namespace: local.workstation)
│               ├── galaxy.yml  # Collection metadata
│               ├── README.md
│               ├── meta/
│               │   └── runtime.yml
│               └── roles/
│                   ├── common/         # Base system configuration
│                   ├── locale/         # English-only environment
│                   ├── git/            # Git configuration with SSH signing
│                   ├── stability/      # Fedora stability & hardening
│                   ├── developer/      # Development tools & runtimes
│                   ├── font/           # Font installation (incl. Thai)
│                   ├── power/          # TLP power management
│                   ├── multimedia/     # Codecs & video acceleration
│                   ├── embed/          # Embedded development (ARM, ESP)
│                   └── docker/         # Docker installation
├── .github/
│   └── workflows/
│       ├── ci.yml              # Main CI/CD pipeline
│       └── tests.yml           # Lint & syntax tests
├── .devcontainer/              # DevContainer configuration
├── .pre-commit-config.yaml     # Pre-commit hooks
├── .ansible-lint               # Ansible-lint configuration
├── .yamllint                   # YAML lint configuration
└── docs/                       # Additional documentation
```

## 2. High-Level System Diagram

This is an **Infrastructure-as-Code (IaC)** project, not a traditional application. The architecture follows Ansible's agentless, push-based configuration management model.

```
┌─────────────────────────────────────────────────────────────────┐
│                         Developer/User                          │
│                    (Runs init.sh or playbook)                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Bootstrap Script (init.sh)                    │
│  - Installs Ansible via DNF                                     │
│  - Installs Galaxy collections                                  │
│  - Configures feature flags                                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Ansible Control Node                         │
│              (Runs on target Fedora workstation)                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    playbook.yaml                         │  │
│  │  - Defines execution order                               │  │
│  │  - Applies 9 roles in sequence                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              local.workstation Collection (Roles)               │
│                                                                 │
│  ┌──────────┐ ┌─────────┐ ┌─────┐ ┌──────────┐ ┌──────────┐   │
│  │  common  │→│ locale  │→│ git │→│stability │→│developer │   │
│  └──────────┘ └─────────┘ └─────┘ └──────────┘ └──────────┘   │
│       ↓              ↓           ↓            ↓                │
│  ┌──────────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐          │
│  │  font    │←│ power   │←│multimedia│←│  embed   │          │
│  └──────────┘ └─────────┘ └──────────┘ └──────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Target System (Fedora)                       │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  DNF/DNF5    │  │   Systemd    │  │  Flatpak     │         │
│  │  Packages    │  │   Services   │  │    Apps      │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ COPR Repos   │  │  Filesystem  │  │   Users &    │         │
│  │ (RPM Fusion) │  │    Config    │  │   Groups     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

**Data Flow**:
1. User runs `init.sh` or `ansible-playbook`
2. Bootstrap installs Ansible and collections
3. Playbook executes roles in sequence on localhost
4. Each role configures specific aspects of the system
5. Changes are applied directly to the target system

## 3. Core Components

### 3.1. Ansible Collection (local.workstation)

**Name**: local.workstation

**Description**: The core automation collection containing all roles for Fedora Workstation configuration. Follows Ansible collection structure with namespace `local` and collection name `workstation`.

**Technologies**: 
- Ansible 2.15+
- YAML (playbooks, tasks, variables)
- Jinja2 (templating)

**Structure**:
- **Roles**: Modular configuration units (common, developer, font, etc.)
- **Galaxy Metadata**: `galaxy.yml` defines collection info and dependencies
- **Runtime Metadata**: `meta/runtime.yml` defines Ansible version requirements

### 3.2. Roles

Each role is a self-contained unit of configuration with its own tasks, variables, handlers, and tests.

#### 3.2.1. common

**Name**: Base System Configuration

**Description**: Core system setup including DNF optimization, RPM Fusion repositories, system updates, firmware management, Fish shell, and system optimizations.

**Key Tasks**:
- DNF configuration and caching
- RPM Fusion repository setup
- System package updates
- Fish shell installation
- System optimizations (hostname, DNS, etc.)

**Technologies**: DNF5, systemd, COPR repositories

#### 3.2.2. developer

**Name**: Development Tools & Runtimes

**Description**: Installs and configures development tooling including compilers, package managers, and SDKs.

**Key Tasks**:
- Node.js, Rust, Go, Python installation
- Bun, uv package managers
- Flutter SDK with Android SDK
- Java (Temurin 17)
- Neovim configuration (LazyVim)

**Technologies**: DNF, SDKMAN, rustup, Flutter, Android SDK

#### 3.2.3. font

**Name**: Font Installation

**Description**: Installs programming fonts and Thai language support.

**Key Tasks**:
- JetBrains Mono (COPR)
- Fira Code, Inter fonts
- Sarabun Thai fonts (from GitHub)
- Font cache refresh

**Technologies**: COPR, fontconfig

#### 3.2.4. stability

**Name**: Fedora Stability & Hardening

**Description**: System stability features including dnf-automatic updates, firewalld, and optional Snapper Btrfs snapshots.

**Levels**:
- Level 1: Basic (dnf-automatic, firewalld)
- Level 2: Snapshot & Rollback (Snapper)
- Level 3: Hardening (sysctl)

#### 3.2.5. embed

**Name**: Embedded Development

**Description**: Tools for embedded systems development.

**Key Tasks**:
- ARM GCC toolchain
- ESP-IDF tools (esptool)
- Serial debugging (minicom)
- Dialout group configuration

#### 3.2.6. locale

**Name**: Locale Configuration

**Description**: Enforces English-only environment for consistent CLI behavior.

**Key Tasks**:
- glibc locale installation
- System locale configuration
- XDG directory setup

#### 3.2.7. git

**Name**: Git Configuration

**Description**: Git setup with optional SSH key signing.

**Key Tasks**:
- Git installation
- SSH key generation
- Commit signing configuration

#### 3.2.8. power

**Name**: Power Management

**Description**: TLP power management for laptops (disabled by default).

**Key Tasks**:
- TLP installation
- power-profiles-daemon removal
- TLP configuration

#### 3.2.9. multimedia

**Name**: Multimedia Codecs

**Description**: Multimedia codec installation and hardware video acceleration.

**Key Tasks**:
- RPM Fusion multimedia packages
- FFmpeg installation
- Hardware acceleration (Intel/AMD)
- OpenH264 (disabled by default)

### 3.3. Bootstrap Script

**Name**: init.sh

**Description**: Bash script that bootstraps the Ansible environment on fresh Fedora installations.

**Features**:
- Installs Ansible via DNF
- Installs Galaxy collections
- Configures feature flags via environment variables
- Hands off to ansible-playbook

**Technologies**: Bash, DNF

## 4. Data Stores

### 4.1. Ansible Fact Cache

**Type**: JSON File Cache

**Location**: `./.ansible/facts/`

**Purpose**: Caches system facts between playbook runs for performance. Configured in `ansible.cfg` with 24-hour timeout.

### 4.2. Inventory Cache

**Type**: JSON File Cache

**Location**: `./.ansible/inventory_cache/`

**Purpose**: Caches inventory parsing results.

### 4.3. Configuration State

**Type**: System Configuration Files

**Locations**:
- `/etc/dnf/` - DNF configuration
- `/etc/systemd/` - Systemd service configuration
- `/etc/profile.d/` - Environment variables
- `~/.bashrc`, `~/.config/` - User configuration
- `/usr/share/fonts/` - System fonts
- `/etc/sysctl.d/` - Kernel parameters

**Purpose**: Persistent system configuration applied by Ansible roles.

## 5. External Integrations / APIs

### 5.1. Fedora COPR Repositories

**Service**: COPR (Cool Other Package Repo)

**Purpose**: Third-party RPM repositories for packages not in official Fedora repos.

**Repositories Used**:
- `jetpack-io/fonts` - JetBrains Mono fonts
- `b00f1nt/inter-fonts` - Inter fonts
- `rpmfusion-free/nonfree` - Multimedia codecs

**Integration Method**: DNF repository configuration

### 5.2. Ansible Galaxy

**Service**: Ansible Galaxy

**Purpose**: External collection dependencies.

**Collections**:
- `community.general` (≥8.0.0) - General purpose modules
- `ansible.posix` (≥1.5.0) - POSIX-specific modules

**Integration Method**: `ansible-galaxy collection install`

### 5.3. GitHub Releases

**Service**: GitHub

**Purpose**: Downloading fonts and tools.

**Used For**:
- Sarabun fonts (from Thai font repository)
- Android SDK command-line tools
- Rust installer (rustup.rs)
- Bun installer (bun.sh)
- UV installer (astral.sh)

**Integration Method**: `ansible.builtin.get_url`

### 5.4. Google (Android)

**Service**: Android SDK Repository

**Purpose**: Android SDK command-line tools.

**URL**: `https://dl.google.com/android/repository/commandlinetools-linux-*.zip`

**Integration Method**: Direct download via `get_url`

## 6. Deployment & Infrastructure

### 6.1. Execution Model

**Type**: Agentless Configuration Management

**Target**: Localhost (Fedora Workstation)

**Connection**: `ansible_connection=local`

**Privilege Escalation**: `become: true` (sudo to root)

### 6.2. CI/CD Pipeline

**Platform**: GitHub Actions

**Workflows**:
1. **Ansible CI Pipeline** (`.github/workflows/ci.yml`)
   - Security Scan (TruffleHog + Checkov)
   - Lint & Syntax Validation (ansible-lint, yamllint, actionlint)
   - Test on Fedora Rawhide (containerized execution)
   - Idempotence check (verify playbook can run twice)
   - Final Report

2. **Tests** (`.github/workflows/tests.yml`)
   - ansible-lint (production profile)
   - YAML lint
   - Playbook syntax check
   - Check mode dry run

**Trigger Events**:
- Push to `main`/`develop` branches
- Pull requests
- Manual workflow dispatch

**Caching**:
- Ansible collections (by `requirements.yml` hash)
- Python virtual environment (by requirements hash)

### 6.3. Monitoring & Logging

**Log File**: `./ansible.log`

**Artifacts**: `./.ansible/artifacts/`

**GitHub Actions Logs**: Uploaded as artifacts for failed runs

**Recovery System**: Roles include recovery tasks with error logging to `/var/log/ansible_recovery_*.marker`

## 7. Security Considerations

### 7.1. Authentication

**Type**: SSH Keys (for Git signing)

**Storage**: `~/.ssh/` (user's existing keys)

**Usage**: Git commit signing (optional)

### 7.2. Privilege Escalation

**Method**: sudo

**Configuration**: All roles run with `become: true`

**Scope**: Root access for system configuration

### 7.3. Data Protection

**In Transit**: HTTPS for all external downloads (GitHub, Google, etc.)

**At Rest**: System file permissions (0644 for configs, 0755 for directories)

**Filtered Data**: Ansible log filtering for passwords/secrets (`log_filter = *password*,*secret*,*key*`)

### 7.4. Security Scanning

**Tools**:
- **TruffleHog**: Secret detection in code
- **Checkov**: Infrastructure-as-Code security scanning

**Integration**: GitHub Actions with SARIF upload to Security tab

**Known Alerts**: Checkov warnings for HTTP URLs (user-configurable webhook URLs)

## 8. Development & Testing Environment

### 8.1. Local Setup

**Requirements**:
- Fedora Linux 40+
- sudo privileges
- Git

**Quick Start**:
```bash
git clone https://github.com/parinya-ao/ansible-config.git
cd ansible-config
./init.sh
```

**Manual Setup**:
```bash
# Install Ansible
sudo dnf install -y ansible

# Install collections
ansible-galaxy collection install -r requirements.yml

# Run playbook
ansible-playbook site.yml -i inventory/hosts
```

### 8.2. Testing Frameworks

**Syntax Validation**:
```bash
ansible-playbook --syntax-check site.yml
```

**Check Mode (Dry Run)**:
```bash
ansible-playbook site.yml -i inventory/hosts --check
```

**Idempotence Test**:
```bash
# First run
ansible-playbook site.yml -i inventory/hosts

# Second run (should show 0 changed)
ansible-playbook site.yml -i inventory/hosts
```

**Linting**:
```bash
ansible-lint --profile production
yamllint -c .yamllint .
```

### 8.3. Code Quality Tools

**ansible-lint**: Production profile enforced in CI

**yamllint**: Custom configuration (`.yamllint`)

**actionlint**: GitHub Actions workflow validation

**shellcheck**: Bash script validation (init.sh)

**pre-commit**: Git pre-commit hooks for automated linting

### 8.4. Development Conventions

**Variable Naming**: Role prefix required (e.g., `common_*`, `developer_*`, `font_*`)

**License Header**: `SPDX-License-Identifier: MIT-0`

**Task Structure**:
```yaml
- name: Descriptive task name
  ansible.builtin.module:
    parameter: value
  register: role_prefix_result
  when: condition
  tags:
    - category
    - subcategory
```

## 9. Future Considerations / Roadmap

### 9.1. Known Architectural Debts

1. **Molecule Testing**: Currently disabled due to Podman-in-Docker compatibility issues in GitHub Actions. Need self-hosted runners or VM-based testing.

2. **Idempotence**: Some roles (locale) have minor idempotence issues (10 changed tasks allowed in CI). Should be addressed for 100% idempotence.

3. **Checkov Alerts**: 5 security alerts for webhook URLs using variables (not hardcoded HTTP). Should add skip comments or validation.

### 9.2. Planned Improvements

1. **Event-Driven Recovery**: Enhanced recovery system with webhook notifications (currently file-based).

2. **Btrfs Snapshot Integration**: Optional Snapper integration for rollback capability (Level 2 stability).

3. **NVIDIA Driver Support**: Currently disabled by default. Consider automated detection and installation.

4. **Container Testing**: Implement proper Molecule tests with Podman native support.

5. **Modular Feature Flags**: More granular control over individual packages within roles.

### 9.3. Scalability Considerations

**Current Scope**: Single workstation (localhost)

**Potential Extensions**:
- Multi-host fleet management
- Group-specific configurations (developers vs. designers)
- Cloud workstation provisioning (AWS WorkSpaces, etc.)

## 10. Project Identification

**Project Name**: Ansible Fedora Workstation Configuration

**Repository URL**: https://github.com/parinya-ao/ansible-config

**Primary Contact/Team**: @parinya-ao

**License**: MIT-0 (No Rights Reserved)

**Date of Last Update**: 2026-03-15

## 11. Glossary / Acronyms

| Term | Definition |
|------|------------|
| **COPR** | Cool Other Package Repo - Fedora's community package repository system |
| **DNF** | Dandified YUM - Fedora's package manager (DNF5 in Fedora 41+) |
| **IaC** | Infrastructure as Code - Managing infrastructure through configuration files |
| **Idempotence** | Property where applying configuration multiple times has same effect as once |
| **COPR** | Community-owned package repository for Fedora |
| **TLP** | Power management tool for Linux laptops |
| **ESP-IDF** | Espressif IoT Development Framework |
| **ARM GCC** | GNU Compiler Collection for ARM architecture |
| **Flatpak** | Universal Linux application packaging system |
| **RPM Fusion** | Third-party repository for Fedora (free and non-free packages) |
| **Checkov** | Infrastructure-as-Code security scanning tool |
| **TruffleHog** | Secret detection tool for Git repositories |
| **Molecule** | Ansible testing framework for role testing |
| **Podman** | Daemonless container engine (alternative to Docker) |
| **Btrfs** | Copy-on-write filesystem with snapshot support |
| **Snapper** | Btrfs snapshot management tool |
| **sysctl** | Linux kernel parameter configuration |
| **Firewalld** | Dynamic firewall management daemon |
| **Temurin** | OpenJDK distribution by Adoptium |
| **LazyVim** | Neovim configuration framework |
