# Ghostty Role

Installs Ghostty terminal emulator on Fedora systems via COPR repository.

## Overview

Ghostty is a fast, feature-rich, and cross-platform terminal emulator. This role automates its installation on Fedora by:
- Enabling the COPR repository
- Installing the Ghostty package
- Creating a working desktop entry file (fixes known issue with missing GUI launcher)
- Optionally creating a configuration template

## Requirements

- Fedora Linux (41, 42, 43, 44, or rawhide)
- Ansible 2.9 or higher
- Root/sudo privileges

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ghostty_install` | `true` | Enable Ghostty installation |
| `ghostty_copr_repo` | `scottames/ghostty` | COPR repository name |
| `ghostty_package` | `ghostty` | Package name |
| `ghostty_create_desktop_entry` | `true` | Create desktop entry file for GUI launcher |
| `ghostty_install_config` | `false` | Create configuration template |
| `ghostty_desktop_entry_path` | `~/.local/share/applications/ghostty.desktop` | Desktop entry location |
| `ghostty_config_dir` | `~/.config/ghostty` | Configuration directory |
| `ghostty_config_file` | `~/.config/ghostty/config` | Configuration file path |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: local.workstation.ghostty
      tags:
        - ghostty
        - terminal
```

### Minimal Installation (No Desktop Entry)

```yaml
- hosts: all
  roles:
    - role: local.workstation.ghostty
      vars:
        ghostty_create_desktop_entry: false
```

## Tags

- `ghostty` - Main tag for all Ghostty tasks
- `copr` - COPR repository tasks
- `install` - Installation tasks
- `desktop` - Desktop entry tasks
- `config` - Configuration tasks

## What This Role Does

1. **Enables COPR Repository** - Adds `scottames/ghostty` repository
2. **Installs Ghostty** - Installs the terminal emulator package
3. **Creates Desktop Entry** - Fixes known issue with missing GUI launcher
4. **Optional Config** - Creates configuration template if enabled

## Desktop Entry Fix

This role addresses a [known issue](https://github.com/scottames/copr/issues/58) where the COPR package doesn't create a proper `.desktop` file. The role creates a working desktop entry at `~/.local/share/applications/ghostty.desktop` with:
- Correct executable path (`/usr/bin/ghostty`)
- GTK single instance support
- Proper icon and categories
- Keyboard shortcut support (Ctrl+Alt+T)

## Usage

### Launch Ghostty

**From Terminal:**
```bash
ghostty
```

**From GUI:**
- Search for "Ghostty" in applications menu
- Or use keyboard shortcut (Ctrl+Alt+T if supported)

### Configuration

Ghostty configuration file location:
```bash
~/.config/ghostty/config
```

Example configuration:
```ini
# Font configuration
font-family = JetBrains Mono

# Theme
theme = system

# Window settings
window-maximize = true

# Terminal behavior
confirm-close-surface = false
```

See [Ghostty Configuration Documentation](https://ghostty.org/docs/config) for all options.

## Verification

After running this role:

```bash
# Check if Ghostty is installed
ghostty --version

# Check COPR repository
dnf copr list | grep ghostty

# Check desktop entry
ls -la ~/.local/share/applications/ghostty.desktop
```

## Troubleshooting

### Desktop Entry Not Appearing

1. **Refresh desktop database:**
   ```bash
   update-desktop-database ~/.local/share/applications
   ```

2. **Log out and log back in** to refresh the application menu

3. **Check file permissions:**
   ```bash
   ls -la ~/.local/share/applications/ghostty.desktop
   ```

### Ghostty Not Starting

1. **Check if installed:**
   ```bash
   which ghostty
   ```

2. **Try running with verbose output:**
   ```bash
   ghostty --help
   ```

3. **Check COPR repository status:**
   ```bash
   dnf copr list | grep ghostty
   ```

## Manual Installation (Without Ansible)

```bash
# Enable COPR repository
sudo dnf copr enable scottames/ghostty

# Install Ghostty
sudo dnf install ghostty

# Create desktop entry (if needed)
cat > ~/.local/share/applications/ghostty.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Ghostty
Type=Application
Comment=A fast, feature-rich, and cross-platform terminal emulator
TryExec=/usr/bin/ghostty
Exec=/usr/bin/ghostty --gtk-single-instance=true
Icon=com.mitchellh.ghostty
Categories=System;TerminalEmulator;
Keywords=terminal;tty;pty;
StartupNotify=true
StartupWMClass=com.mitchellh.ghostty
Terminal=false
Actions=new-window;
X-GNOME-UsesNotifications=true
X-KDE-Shortcuts=Ctrl+Alt+T

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/ghostty --gtk-single-instance=true
EOF
```

## References

- [Ghostty Official Website](https://ghostty.org/)
- [Ghostty Documentation](https://ghostty.org/docs)
- [COPR Repository](https://copr.fedorainfracloud.org/coprs/scottames/ghostty/)
- [GitHub Issue: Desktop File](https://github.com/scottames/copr/issues/58)

## License

MIT

## Author

Your Name
