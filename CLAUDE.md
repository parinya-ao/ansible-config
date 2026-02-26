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
│   ├── locale/           # English-only environment enforcement (system locale, XDG dirs, input methods)
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

## Role Overview

### locale - English-Only Environment Enforcement

The `locale` role enforces a strict English-only environment on Fedora Workstation through state-driven Ansible tasks:

| Task File | Purpose |
|-----------|---------|
| `system_locale.yml` | Configures `/etc/locale.conf`, `/etc/environment` |
| `xdg_dirs.yml` | Migrates localized XDG directories to English |
| `input_method.yml` | Configures ibus/fcitx5 for English input |
| `cli_language.yml` | Enforces locale in shell profiles |

**Key Variables** (with `locale_` prefix):
- `locale_lang`: Target locale (default: `en_US.UTF-8`)
- `locale_input_method`: Input framework (`ibus` or `fcitx5`)
- `locale_remove_secondary_layouts`: Remove non-English keyboard layouts
- `locale_secondary_layouts`: List of secondary layouts to keep (e.g., `["th"]`)

**Feature Toggles**:
- `locale_configure_system_locale: true`
- `locale_configure_xdg_dirs: true`
- `locale_configure_input_method: true`
- `locale_enforce_cli_language: true`

<<<<<<< Updated upstream
=======
### font - Font Installation

The `font` role installs programming fonts from both COPR repositories and local files:

**COPR Fonts** (installed via DNF):
- JetBrains Mono
- Fira Code
- Inter
- Arimo
- IBM Plex Sans Thai

**Local Font Files**:
- Arial (4 variants: regular, bold, italic, bold italic)
- Courier (regular)
- THSarabunNew (4 variants)
- Verdana (4 variants)

> **Note**: The local font files in `roles/font/files/` are binary assets that bloat the Git repository. Consider using Git LFS to manage these files:

```bash
# Install Git LFS
git lfs install

# Track font files
git lfs track "roles/font/files/*.ttf"
git lfs track "roles/font/files/*.otf"

# Commit the .gitattributes changes
git add .gitattributes
git commit -m "chore: track font files with Git LFS"
```

**Key Variables** (with `font_` prefix):
- `font_install_enabled`: Toggle font role (default: `true`)
- `font_sarabun_install_enabled`: Install Sarabun Thai font (default: `true`)

>>>>>>> Stashed changes
## Documentation References

- Role-specific details: See each role's `README.md` or `defaults/main.yml`
- CI/CD pipeline: `.github/workflows/ci.yml`
- Ansible collection requirements: `requirements.yml`
