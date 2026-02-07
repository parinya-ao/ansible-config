# Desktop Role

This role configures a GNOME-based desktop environment on Fedora systems with essential applications and tools for desktop productivity.

## Role Purpose

The desktop role automates the setup of a fully-functional desktop environment including:
- Desktop package management (Flatpak)
- GNOME utilities and extensions
- Visual Studio Code IDE with Microsoft repository
- Starship prompt configuration
- Essential flatpak applications (Discord, Bruno, Signal, OBS, Anki)

## Requirements

- Fedora-based system
- `common` role (as a dependency for base system configuration)

## Role Variables

### Default Variables (`defaults/main.yml`)

Currently uses the standard application list. Can be overridden for custom application selections.

### Included Tasks

The role is organized into the following task modules:

- **packages.yml**: Installs base desktop packages, flatpak, and GNOME utilities
  - flatpak
  - okular (PDF viewer)
  - xclip
  - gnome-extensions-app
  - gnome-tweaks

- **vscode.yml**: Installs Visual Studio Code
  - Adds Microsoft GPG key
  - Configures Microsoft yum repository
  - Installs VS Code package

- **starship.yml**: Installs and configures Starship prompt
  - Downloads and installs Starship
  - Configures bash initialization for all users

- **flatpak-apps.yml**: Installs flatpak applications
  - Discord
  - Bruno
  - Signal
  - OBS Studio
  - Anki

## Dependencies

- **common**: Base system configuration role

## Example Playbook

```yaml
---
- hosts: desktop_hosts
  roles:
    - desktop
```

## Advanced Usage

Override specific applications:

```yaml
---
- hosts: desktop_hosts
  roles:
    - role: desktop
      vars:
        flatpak_apps:
          - com.discordapp.Discord
          - org.signal.Signal
```

## Author

Ansible Desktop Configuration

## License

MIT-0
