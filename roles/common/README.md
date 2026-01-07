# Common Role

This role provides base system configuration for Fedora/RHEL systems, including DNF package manager optimization, system updates, and essential package installation.

## Role Purpose

The common role serves as the foundation for system configuration by:
- Optimizing DNF package manager performance (parallel downloads, fastest mirror, delta RPMs)
- Performing full system updates
- Installing essential base packages for all system types
- Configuring firewalld service

This role should be run first on all systems as a prerequisite for other roles.

## Requirements

- RHEL/Fedora-based system (Fedora 39+, RHEL 9+)
- Ansible 2.15+
- Root or sudo access

## Role Variables

### Feature Toggles

```yaml
# Enable/disable full system update
common_system_update_enabled: true

# Enable/disable firewalld service
common_firewalld_enabled: true
```

### DNF Configuration

```yaml
# Maximum parallel downloads (default: 20)
common_dnf_max_parallel_downloads: 20

# Enable fastest mirror selection (default: true)
common_dnf_fastestmirror: "True"

# Enable delta RPMs for faster updates (default: true)
common_dnf_deltarpm: "True"

# Retry settings for network resilience
common_dnf_retries: 3
common_dnf_delay: 10
```

### Base Packages

Default list of packages installed by this role:

```yaml
common_base_packages:
  - curl              # Command line tool for transferring data
  - wget              # Network utility to retrieve files
  - zram-generator    # Compressed swap device generator
  - git               # Version control system
  - htop              # Interactive process viewer
  - dnf-plugins-core  # Core DNF plugins
  - python3           # Python 3 interpreter
  - python3-pip       # Python package manager
  - firewalld         # Firewall daemon
```

### Additional Packages

Extend the base package list:

```yaml
common_extra_packages:
  - vim
  - tmux
  - rsync
```

## Dependencies

None. This is the base role and should not have dependencies.

## Example Playbook

### Basic Usage

```yaml
---
- hosts: all
  roles:
    - common
```

### Custom Configuration

```yaml
---
- hosts: servers
  roles:
    - role: common
      vars:
        # Skip system update (faster execution)
        common_system_update_enabled: false

        # Increase parallel downloads
        common_dnf_max_parallel_downloads: 30

        # Add extra packages
        common_extra_packages:
          - vim
          - tmux
          - ripgrep
          - fd-find
```

### Selective Installation with Tags

```bash
# Configure DNF only
ansible-playbook playbook.yml --tags "dnf"

# Run system update only
ansible-playbook playbook.yml --tags "system-update"

# Install packages only
ansible-playbook playbook.yml --tags "packages"

# Skip system update
ansible-playbook playbook.yml --skip-tags "system-update"
```

## Directory Structure

```
roles/common/
├── defaults/
│   └── main.yml          # Default variables
├── handlers/
│   └── main.yml          # Handlers for service changes
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   ├── main.yml          # Main entry point
│   ├── dnf.yml           # DNF configuration
│   ├── system-update.yml # System package update
│   └── packages.yml      # Base packages installation
├── tests/
│   ├── inventory
│   └── test.yml
├── vars/
│   └── main.yml          # Role variables (empty, using defaults)
└── README.md             # This file
```

## DNF Configuration Details

This role configures the following DNF settings in `/etc/dnf/dnf.conf`:

```ini
max_parallel_downloads=20
fastestmirror=True
deltarpm=True
```

These settings:
- **max_parallel_downloads**: Speeds up package installation by downloading multiple packages simultaneously
- **fastestmirror**: Automatically selects the fastest mirror based on connection speed
- **deltarpm**: Reduces download size by only downloading changed portions of RPM packages

## License

MIT-0

## Author

Ansible Common Configuration
