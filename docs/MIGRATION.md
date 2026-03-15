# Migration to ansible-creator Standards

This document describes the migration from a legacy Ansible project structure to the ansible-creator standard format.

## Changes Made

### 1. Collection Structure

**Before:**
```
roles/
├── common/
├── developer/
└── ...
```

**After:**
```
collections/ansible_collections/local/workstation/
├── galaxy.yml              # Collection metadata
├── README.md               # Collection documentation
├── meta/runtime.yml        # Ansible version requirements
├── .gitignore              # Collection-specific ignores
└── roles/
    ├── common/
    ├── developer/
    └── ...
```

### 2. Entry Point

**Before:**
- `playbook.yaml` - Main entry point

**After:**
- `site.yml` - Standard entry point (ansible-creator convention)
- `playbook.yaml` - Actual playbook configuration (imported by site.yml)

### 3. Inventory

**Before:**
- `inventory.ini` - INI format inventory

**After:**
- `inventory/hosts` - YAML/INI format in dedicated directory
- `inventory/group_vars/all.yml` - Group variables

### 4. Configuration Files Added

- `.devcontainer/devcontainer.json` - DevContainer support
- `ansible-navigator.yml` - Ansible Navigator configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.yamllint` - YAML lint configuration
- `.github/workflows/tests.yml` - CI/CD pipeline
- `.github/CODEOWNERS` - Code ownership

### 5. Role References Updated

**Before:**
```yaml
roles:
  - role: common
  - role: developer
```

**After:**
```yaml
roles:
  - role: local.workstation.common
  - role: local.workstation.developer
```

### 6. Requirements Updated

**Before:**
```yaml
collections:
  - name: community.general
  - name: ansible.posix
```

**After:**
```yaml
collections:
  - name: community.general
  - name: ansible.posix
  - name: local.workstation
    source: ./collections/ansible_collections/local/workstation
    type: dir
```

### 7. Documentation Updated

- `README.md` - Updated for collection-based structure
- `ARCHITECTURE.md` - Comprehensive architecture documentation
- Collection `README.md` - Collection-specific documentation

### 8. Configuration Simplified

- `ansible.cfg` - Streamlined configuration
- `pyproject.toml` - Python project configuration for development

## Usage Changes

### Running the Playbook

**Before:**
```bash
ansible-playbook playbook.yaml -i inventory.ini
```

**After:**
```bash
# Install collection dependencies first
ansible-galaxy collection install -r requirements.yml

# Run via standard entry point
ansible-playbook site.yml -i inventory/hosts
```

### Running Specific Roles

**Before:**
```bash
ansible-playbook playbook.yaml -i inventory.ini --tags font
```

**After:**
```bash
ansible-playbook site.yml -i inventory/hosts --tags font
```

### Linting

**Before:**
```bash
ansible-lint --profile production
```

**After:**
```bash
# Same command, now with pre-commit support
pre-commit run ansible-lint

# Or direct
ansible-lint --profile production
```

## Benefits of Migration

1. **Standard Structure**: Follows ansible-creator conventions
2. **Collection-Based**: Easier to distribute and version
3. **Better Organization**: Clear separation between project and collection
4. **CI/CD Ready**: GitHub Actions workflow included
5. **DevContainer Support**: Ready for VS Code development
6. **Pre-commit Hooks**: Automated code quality checks
7. **Better Documentation**: Comprehensive architecture docs

## Migration Date

2026-03-14

## Backward Compatibility

The old `playbook.yaml` is still functional but should not be used directly.
Use `site.yml` as the entry point going forward.

## Next Steps

1. Update CI/CD pipelines to use new structure
2. Update any automation scripts referencing old paths
3. Consider publishing collection to Ansible Galaxy (optional)
4. Update documentation links and references
