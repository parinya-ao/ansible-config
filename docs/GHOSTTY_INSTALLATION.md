# Ghostty Terminal - Quick Installation Guide

## Automated Installation (Ansible)

```bash
cd /home/parinya/ansible-config
ansible-playbook playbook.yaml --tags ghostty
```

## Manual Installation

### 1. Enable COPR Repository

```bash
sudo dnf copr enable scottames/ghostty
```

### 2. Install Ghostty

```bash
sudo dnf install ghostty
```

### 3. Verify Installation

```bash
ghostty --version
```

## Desktop Entry (If Missing)

If Ghostty doesn't appear in your applications menu, create this file:

**File:** `~/.local/share/applications/ghostty.desktop`

```ini
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
```

Then refresh the desktop database:

```bash
update-desktop-database ~/.local/share/applications
```

## Configuration

**Config file location:** `~/.config/ghostty/config`

### Example Configuration

```ini
# Font configuration
font-family = JetBrains Mono
font-size = 12

# Theme
theme = system

# Window settings
window-maximize = true
window-padding-x = 10
window-padding-y = 10

# Cursor
cursor-style = block
cursor-style-blink = true

# Bell
audible-bell = false

# Selection
copy-on-select = true
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Shift+N` | New window |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |
| `Ctrl++` | Zoom in |
| `Ctrl+-` | Zoom out |
| `Ctrl+0` | Reset zoom |

## Features

- ⚡ **Fast** - GPU-accelerated rendering
- 🎨 **Ligatures** - Full font ligature support
- 🖼️ **Images** - Inline image support
- 📑 **Tabs** - Native tab support
- 🎯 **Hyperlinks** - Clickable URLs
- ⌨️ **Shortcuts** - Customizable keyboard shortcuts
- 🌙 **Themes** - Built-in and custom themes
- 🔧 **Config** - Simple configuration file

## Troubleshooting

### Ghostty Not in Applications Menu

```bash
# Check if desktop file exists
ls -la ~/.local/share/applications/ghostty.desktop

# Refresh desktop database
update-desktop-database ~/.local/share/applications

# Log out and log back in
```

### Font Issues

```bash
# List available fonts
fc-list | grep -i "jetbrains\|mono"

# Install JetBrains Mono (if not installed)
sudo dnf install fira-code-fonts
```

### Performance Issues

```bash
# Check GPU acceleration
glxinfo | grep "OpenGL renderer"

# Run with verbose output
ghostty --help
```

## Uninstall

```bash
# Remove package
sudo dnf remove ghostty

# Disable COPR repository
sudo dnf copr remove scottames/ghostty

# Remove configuration (optional)
rm -rf ~/.config/ghostty
rm ~/.local/share/applications/ghostty.desktop
```

## Resources

- [Official Website](https://ghostty.org/)
- [Documentation](https://ghostty.org/docs)
- [GitHub](https://github.com/ghostty-org/ghostty)
- [COPR Repository](https://copr.fedorainfracloud.org/coprs/scottames/ghostty/)
