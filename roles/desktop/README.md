# Desktop Role

This role configures a GNOME-based desktop environment on Fedora systems with essential applications and tools for desktop productivity.

## Role Purpose

The desktop role automates the setup of a fully-functional desktop environment including:
- Desktop package management (Flatpak)
- GNOME utilities and RPM-based extensions
- GNOME Shell extensions from extensions.gnome.org (Dash to Panel, ArcMenu)
- Starship prompt configuration
- Essential flatpak applications (Discord, Bruno, Signal, OBS, Anki)

## Requirements

- Fedora-based system
- `common` role (as a dependency for base system configuration)

## Role Variables

### Default Variables (`defaults/main.yml`)

```yaml
# Feature flags
desktop_install_shell_extensions: true

# GNOME Shell extensions from extensions.gnome.org
desktop_shell_extensions_list:
  - name: "Dash to Panel"
    url: "https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v60.shell-extension.zip"
    uuid: "dash-to-panel@jderose9.github.com"
    enabled: true
  - name: "ArcMenu"
    url: "https://extensions.gnome.org/extension-data/arcmenuprojectarcmenu.com.v45.shell-extension.zip"
    uuid: "arcmenu@arcmenu.com"
    enabled: true

# Dash to Panel settings
desktop_dashtopanel_position: "BOTTOM"    # TOP, BOTTOM, LEFT, RIGHT
desktop_dashtoppanel_show_apps: true       # Show apps button
```

### Included Tasks

The role is organized into the following task modules:

- **packages.yml**: Installs base desktop packages, flatpak, and GNOME utilities
  - flatpak
  - okular (PDF viewer)
  - xclip
  - gnome-extensions-app
  - gnome-tweaks

- **gnome-extensions.yml**: Installs GNOME extensions from RPM packages
  - gnome-shell-extension-pop-shell
  - nautilus-python (for GSConnect)

- **shell-extensions.yml**: Installs GNOME Shell extensions from extensions.gnome.org
  - Dash to Panel (Windows-like taskbar at bottom)
  - ArcMenu (start menu replacement)
  - Automatically enables extensions via gsettings
  - Configures Dash to Panel position and behavior

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

### GNOME Shell Extensions Configuration

Customize extension settings:

```yaml
---
- hosts: desktop_hosts
  roles:
    - role: desktop
      vars:
        # Change Dash to Panel position
        desktop_dashtopanel_position: "TOP"  # TOP, BOTTOM, LEFT, RIGHT

        # Disable specific extensions
        desktop_shell_extensions_list:
          - name: "Dash to Panel"
            enabled: false
          - name: "ArcMenu"
            enabled: true
```

Run only GNOME extensions:
```bash
sudo ansible-playbook playbook.yaml -i inventory --tags gnome,extensions
```

## Author

Ansible Desktop Configuration

## License

MIT-0
