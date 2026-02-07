# Ansible Workstation Setup

Automated workstation onboarding for Fedora hosts so developers can get from zero to a consistent desktop + tooling stack with one playbook run.

## Table of Contents
- [What It Covers](#what-it-covers)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Customization](#customization)
- [Testing & CI](#testing--ci)
- [How to Use](#how-to-use)
- [Project Status](#project-status)
- [Contribution](#contribution)
- [License](#license)

## What It Covers
- **Common**: Optimize DNF, run system updates, install core packages (git, curl, python3, etc.), and configure maintenance timers.
- **Docker**: Install Docker CE, Docker Compose, and manage the docker group for the host user.
- **Desktop**: Deploy Brave, VSCode, Discord, Bruno, Signal, Starship prompt, Flatpak apps, and GNOME defaults.
- **Developer**: Provision language runtimes (Rust, Go, Node.js, Bun, Python tooling), compilers, shells, and editors.
- **Security**: Harden SSH, firewalld, and custom port policies through dedicated security roles.

## Tech Stack
- **Provisioning**: Ansible 2.13+ / ansible-core 2.14 (targeting Fedora).
- **Collections**: `community.general` for Flatpak/dconf and `ansible.posix` through included roles.
- **CI**: GitHub Actions workflow at `.github/workflows/ci.yml` performs ansible-lint, syntax checks, Fedora container tests, and a report job.

## Quick Start
```bash
ansible-playbook playbook.yaml -i inventory.ini
```
Add `-e ansible_user=...` or limit the run via `--tags common` to scope what executes on a host.

## Customization
- Role config files live under `roles/<role-name>/tasks/` and can be modified to adjust packages or services.
- Override defaults via `roles/<role-name>/defaults/main.yml` and keep inventory groups in `inventory.ini` aligned with the target hosts.
- Store sensitive variables outside the repo (e.g., Ansible Vault) and reference them when feeding `ansible-playbook`.

## Testing & CI
- Local linting: `ansible-lint playbook.yaml roles/`, `yamllint -d relaxed .`, `ansible-playbook --syntax-check playbook.yaml`.
- GitHub workflow runs on `main`/`develop`, riffs through union of lint, Fedora tests (with Xvfb/DBus for GNOME), and a post-run report.
- Container validation replicates real installs by installing Python 3.12, Ansible core, required collections, and executing tagged dry-runs.

## How to Use
1. Ensure `inventory.ini` points to your workstation targets.
2. If needed, bootstrap dependencies with `./init.sh` (installs pip, etc.).
3. Run the playbook: `ansible-playbook playbook.yaml -i inventory.ini`.
4. To iteratively validate a role, run `ansible-playbook roles/<role-name>/tasks/main.yml --syntax-check`.
5. When customizing GNOME settings, ensure Xvfb is available for GUI-linked tasks.

## Project Status
- Active: Maintainers regularly update role defaults, packages, and desktop tweaks.
- CI: `ci.yml` enforces syntax, lints, and Fedora validation; CI report job fails if any dependency job does not succeed.

## Contribution
1. Fork, branch from `develop`, and update relevant role/task files.
2. Run local checks (lint, syntax, and optionally targeted role dry-runs).
3. Push your changes with a descriptive PR that summarizes scope and tests performed.
4. Preserve code style in Ansible/YAML and describe configuration expectations in role README files.

## License
MIT-0. See LICENSE for details.
