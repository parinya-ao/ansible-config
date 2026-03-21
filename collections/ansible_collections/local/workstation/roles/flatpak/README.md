# Flatpak Role

Installs and manages Flatpak applications on Fedora systems.

## Overview

This role automates Flatpak setup and application installation:
- Installs Flatpak package
- Enables Flathub repository
- Installs specified Flatpak applications
- Updates applications
- Cleans up unused runtimes

## Requirements

- Fedora Linux (any supported version)
- Ansible 2.9 or higher
- Root/sudo privileges

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `flatpak_enabled` | `true` | Enable Flatpak management |
| `flatpak_install_package` | `true` | Install Flatpak if not present |
| `flatpak_enable_flathub` | `true` | Enable Flathub repository |
| `flatpak_apps` | (list) | List of Flatpak applications to install |
| `flatpak_update_apps` | `true` | Update apps after installation |
| `flatpak_remove_unused_runtimes` | `false` | Remove unused runtimes |
| `flatpak_auto_update` | `false` | Enable auto-updates |

## Default Applications

The following applications are configured (enable by setting `enabled: true`):

| Application | Flatpak ID | Category |
|-------------|------------|----------|
| Signal | `org.signal.Signal` | Communication |
| VLC | `org.videolan.VLC` | Media |
| OBS Studio | `md.obs.Studio` | Development |
| LibreOffice | `org.libreoffice.LibreOffice` | Productivity |
| GIMP | `org.gimp.GIMP` | Graphics |
| Chromium | `org.chromium.Chromium` | Browser |

## Example Playbook

### Install Popular Applications

```yaml
- hosts: all
  roles:
    - role: local.workstation.flatpak
      vars:
        flatpak_apps:
          - name: org.signal.Signal
            enabled: true
          - name: org.videolan.VLC
            enabled: true
          - name: md.obs.Studio
            enabled: true
```

### Install All Applications

```yaml
- hosts: all
  roles:
    - role: local.workstation.flatpak
      vars:
        flatpak_apps:
          - name: org.signal.Signal
            enabled: true
          - name: org.videolan.VLC
            enabled: true
          - name: md.obs.Studio
            enabled: true
          - name: org.libreoffice.LibreOffice
            enabled: true
          - name: org.gimp.GIMP
            enabled: true
          - name: org.chromium.Chromium
            enabled: true
```

### Minimal Installation (No Apps)

```yaml
- hosts: all
  roles:
    - role: local.workstation.flatpak
      vars:
        flatpak_install_package: true
        flatpak_enable_flathub: true
        flatpak_apps: []
```

## Tags

- `flatpak` - Main tag for all Flatpak tasks
- `install` - Installation tasks
- `repository` - Repository configuration
- `update` - Update tasks
- `cleanup` - Cleanup tasks
- `list` - List installed applications

## What This Role Does

1. **Installs Flatpak** - Installs `flatpak` and `flatpak-selinux` packages
2. **Enables Flathub** - Adds Flathub repository
3. **Installs Applications** - Installs enabled Flatpak apps
4. **Updates Apps** - Updates all installed Flatpak applications
5. **Optional Cleanup** - Removes unused runtimes

## Why Use Flatpak?

Flatpak applications are:
- **Sandboxed** - More secure than traditional packages
- **Self-contained** - Include all dependencies
- **Cross-distro** - Work on any Linux distribution
- **Up-to-date** - Latest versions from developers
- **No conflicts** - Don't interfere with system packages

## Verification

After running this role:

```bash
# List installed Flatpak applications
flatpak list

# Check Flathub repository
flatpak remotes

# Search for applications
flatpak search <application-name>

# Update all applications
flatpak update
```

## Manual Installation (Without Ansible)

```bash
# Install Flatpak
sudo dnf install flatpak flatpak-selinux

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install flathub org.signal.Signal
flatpak install flathub org.videolan.VLC
flatpak install flathub md.obs.Studio

# List installed apps
flatpak list
```

## Common Flatpak Commands

```bash
# Install application
flatpak install flathub <app-id>

# Remove application
flatpak uninstall <app-id>

# Update all applications
flatpak update

# List installed applications
flatpak list

# Run application
flatpak run <app-id>

# Show application info
flatpak info <app-id>

# Remove unused runtimes
flatpak uninstall --unused
```

## Troubleshooting

### Flatpak Apps Not Appearing in Menu

1. **Refresh desktop database:**
   ```bash
   update-desktop-database
   ```

2. **Log out and log back in**

3. **Check installation:**
   ```bash
   flatpak list --app
   ```

### Installation Fails

1. **Check disk space:**
   ```bash
   df -h
   ```

2. **Check Flathub connectivity:**
   ```bash
   curl -I https://flathub.org
   ```

3. **Repair Flatpak installation:**
   ```bash
   sudo flatpak repair --system
   ```

### Permission Denied

Run Flatpak commands with `--user` flag for user-level installation:
```bash
flatpak install --user flathub <app-id>
```

## References

- [Flatpak Official Site](https://flatpak.org/)
- [Flathub](https://flathub.org/)
- [Flatpak Documentation](https://docs.flatpak.org/)
- [Fedora Flatpak Guide](https://docs.fedoraproject.org/en-US/quick-docs/flatpak/)

## License

MIT

## Author

Your Name
