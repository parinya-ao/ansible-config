# Ansible Workstation Setup

Automated setup for Fedora/RHEL development workstation.

## What It Does

- **Common**: DNF optimization, system updates, base packages (git, curl, python3)
- **Docker**: Docker CE and Docker Compose
- **Desktop**: Brave, VSCode, Discord, Postman, Signal
- **Developer**: Rust, Go, Fish shell, Node.js, Bun, Neovim

## Quick Start

```bash
ansible-playbook playbook.yaml
```

## Post-Install

- Log out and back in for docker group to take effect
- Fish shell is now your default shell

## Customize

Edit roles in `roles/<role-name>/tasks/main.yml` to add/remove packages.
