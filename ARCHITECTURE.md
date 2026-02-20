# Architecture Overview

This document provides a high-level map of the Ansible Fedora Workstation configuration project. Use it to navigate the codebase and understand where things live and why.

## 1. Project Structure

```
ansible-config/
├── playbook.yaml              # Main entry point - orchestrates all roles
├── init.sh                    # Bootstrap: creates venv, installs Ansible, runs playbook
├── inventory.ini              # Localhost inventory definition
├── requirements.yml           # Ansible Galaxy collection dependencies
├── ansible.cfg                # Ansible runtime configuration
│
├── roles/                     # All provisioning logic lives here
│   ├── common/               # Base system: DNF, RPM Fusion, updates, firmware
│   ├── locale/               # English-only enforcement: system locale, XDG dirs, input methods
│   ├── desktop/              # GUI: GNOME, Flatpak, Ghostty, Starship
│   ├── developer/            # Dev tools: compilers, Bun, Python (uv), Flutter, Android SDK
│   ├── docker/               # Docker CE installation and configuration
│   ├── git/                  # Git config with SSH key signing
│   ├── font/                 # Programming fonts installation
│   ├── wifi/                 # Wi-Fi performance optimization
│   └── multimedia/           # Codecs, FFmpeg, hardware acceleration
│
├── .github/workflows/        # CI: security scan, lint, Fedora container tests
└── .ansible/                 # Ansible lint configuration
```

## 2. High-Level System Diagram

```
[User runs ./init.sh -K]
         |
         v
[init.sh] ──> Creates .ansible-venv/ ──> Installs ansible-core ──> Installs collections
         |
         v
[ansible-playbook playbook.yaml]
         |
         +──> [common]    ──> Base system packages, RPM Fusion, updates
         |
         +──> [locale]    ──> System locale, XDG dirs, input methods
         |
         +──> [desktop]   ──> GUI apps, Flatpak, terminal
         |
         +──> [developer] ──> Compilers, runtimes, SDKs
         |
         +──> [docker]    ──> Docker CE
         |
         +──> [git]       ──> Git configuration
         |
         +──> [font]      ──> Fonts
         |
         +──> [wifi]      ──> Wi-Fi optimization
         |
         +──> [multimedia]──> Codecs, hardware acceleration
```

## 3. Core Components

### 3.1. Bootstrap Layer (`init.sh`)

**Purpose**: Environment setup only. Does not contain provisioning logic.

**Responsibilities**:
- Create Python virtual environment at `.ansible-venv/`
- Install `ansible-core` via pip
- Install Ansible collections from `requirements.yml`
- Hand off execution to `ansible-playbook`

**Key invariant**: Bash handles environment setup only. Ansible handles all provisioning logic.

### 3.2. Playbook Layer (`playbook.yaml`)

**Purpose**: Orchestration. Imports and runs roles in dependency order.

**Structure**:
- Imports `preflight.yml` from each role before main tasks
- Runs roles in sequence: common → locale → desktop → developer → docker → git → font → wifi → multimedia
- Each role has a tag matching its name for selective execution

### 3.3. Role Layer (`roles/<name>/`)

Each role follows standard Ansible structure:

```
roles/<name>/
├── tasks/
│   ├── main.yml        # Entry point, imports other task files
│   ├── preflight.yml   # Validation runs before main tasks
│   └── *.yml           # Feature-specific task files
├── defaults/
│   └── main.yml        # Default variables (lowest precedence)
├── handlers/
│   └── main.yml        # Handlers for service restarts, etc.
└── README.md           # Role documentation
```

**Role Dependencies**:
- `common` must run first (installs DNF plugins, enables RPM Fusion)
- `locale` should run early (affects display language)
- `desktop` and `developer` depend on `common` for package management
- Other roles are independent

## 4. Key Architectural Invariants

1. **Local execution only**: `ansible_connection=local` - no remote hosts
2. **Fedora only**: All roles assert `ansible_distribution == "Fedora"`
3. **Idempotency**: All tasks must be safe to run multiple times (verified in CI)
4. **Variable naming**: Registered variables use role prefix (e.g., `locale_*`, `docker_*`)
5. **State-driven tasks**: Task names prefixed with `STATE:`, `GATHER:`, `VERIFY:`
6. **Feature toggles**: Boolean variables control optional features (e.g., `locale_configure_xdg_dirs`)

## 5. Data Flow

```
[Role defaults]          [Inventory vars]        [CLI extra vars]
(defaults/main.yml)  →   (inventory.ini)   →    (-e "key=value")
                           │
                           v
                    [Variable precedence]
                           │
                           v
                    [Task execution]
                           │
                           v
                    [Fact caching]
                  (.ansible/facts/)
```

**Fact Caching**: Enabled via `jsonfile` plugin at `./.ansible/facts/` with 24-hour timeout. Reduces redundant setup calls.

## 6. External Integrations

| Service | Purpose | Used By |
|---------|---------|---------|
| RPM Fusion | Third-party packages | `common` role |
| Flathub | Flatpak applications | `desktop` role |
| GitHub Fonts | JetBrains Mono, etc. | `font` role |
| Docker CE Repo | Container runtime | `docker` role |

## 7. Deployment & Infrastructure

**Execution Environment**:
- Target: Local Fedora Workstation
- Privilege escalation: `sudo` (password via `-K` flag)
- Python: Virtual environment at `.ansible-venv/`

**CI Pipeline** (`.github/workflows/ci.yml`):
1. Security scan: TruffleHog, KICS
2. Lint: ansible-lint with `production` profile
3. Test: Fedora container with idempotence check

## 8. Development Workflow

```bash
# Lint and auto-fix
ansible-lint --profile production --fix roles/

# Run specific role
ansible-playbook playbook.yaml --tags docker -K

# Full run
./init.sh -K
```

## 9. Cross-Cutting Concerns

### Error Handling
- Preflight tasks validate prerequisites before main execution
- Tasks use `ignore_errors: true` only when explicitly handling expected failures
- Failed tasks include descriptive `fail_msg` for debugging

### Logging & Output
- `profile_tasks` callback enabled for timing information
- YAML output format via `stdout_callback = ansible.builtin.default`
- CI artifacts include ansible run logs for debugging

### License
All files use `SPDX-License-Identifier: MIT-0` header.

## 10. Project Identification

| Field | Value |
|-------|-------|
| Project Name | Ansible Fedora Workstation Configuration |
| Repository | (local) |
| Target OS | Fedora Workstation |
| Last Updated | 2025-02-20 |

## 11. Glossary

| Term | Definition |
|------|------------|
| Role | Ansible's unit of organization for automation content |
| Playbook | YAML file defining plays (mapping hosts to roles) |
| Preflight | Validation tasks that run before main provisioning |
| Idempotency | Property where running multiple times produces same result |
| XDG dirs | XDG Base Directory Specification (standard user directories) |
| RPM Fusion | Third-party repository for Fedora |
| Flatpak | Cross-distribution application sandboxing system |
