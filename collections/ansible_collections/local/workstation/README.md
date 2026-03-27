# Local Workstation Collection

Fedora Workstation automation collection for Ansible.

## Description

This collection provides roles for automating Fedora/Ultramarine Workstation setup, including:

- System configuration and optimization
- Development tools and runtimes
- Desktop environment setup
- Multimedia codecs

**Note**: Ultramarine Linux includes Podman pre-installed by default.

## Included Content

### Roles

- `common` - Base system configuration (DNF, RPM Fusion, updates)
- `locale` - English-only environment enforcement
- `git` - Git configuration with SSH signing
- `stability` - Fedora stability and hardening
- `developer` - Development tools and runtimes
- `multimedia` - Multimedia codecs
- `embed` - Embedded development tools

## Installation

```bash
ansible-galaxy collection install local.workstation
```

Or use the local path:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Usage

Include roles in your playbook:

```yaml
- hosts: localhost
  roles:
    - local.workstation.common
    - local.workstation.developer
```

## License

MIT-0

## Contact

For issues, please open a GitHub issue.
