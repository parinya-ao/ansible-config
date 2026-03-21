# RPM Fusion Role

Enables RPM Fusion repositories (Free and Non-Free) on Fedora systems and installs non-free firmware packages.

## Overview

This role configures RPM Fusion repositories which provide:
- Multimedia codecs (H.264, H.265/HEVC, etc.)
- Non-free firmware for various hardware
- Proprietary drivers (NVIDIA, Broadcom, etc.)
- Additional software not included in Fedora

## Requirements

- Fedora Linux (any supported version)
- Ansible 2.9 or higher
- Root/sudo privileges

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `rpmfusion_enable_free` | `true` | Enable RPM Fusion Free repository |
| `rpmfusion_enable_nonfree` | `true` | Enable RPM Fusion Non-Free repository |
| `rpmfusion_install_tainted` | `true` | Install tainted firmware repository |
| `rpmfusion_install_appstream` | `true` | Install AppStream metadata for GNOME Software/KDE Discover |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: local.workstation.rpmfusion
      tags:
        - rpmfusion
        - repositories
```

## Tags

- `rpmfusion` - Main tag for all RPM Fusion tasks
- `repositories` - Repository installation tasks
- `firmware` - Firmware-related tasks
- `appstream` - AppStream metadata installation

## What This Role Does

1. **Installs RPM Fusion Free Repository** - Provides open-source software that Fedora cannot ship
2. **Installs RPM Fusion Non-Free Repository** - Provides proprietary software and drivers
3. **Installs Tainted Firmware** - Enables non-free firmware packages for hardware support
4. **Installs AppStream Metadata** - Enables software installation via GNOME Software/KDE Discover

## Post-Installation

After running this role, you can:
- Install multimedia codecs: `sudo dnf install ffmpeg`
- Install NVIDIA drivers: `sudo dnf install akmod-nvidia`
- Install additional firmware: `sudo dnf install '*-firmware'`

## References

- [RPM Fusion Official Site](https://rpmfusion.org/)
- [RPM Fusion Howto](https://rpmfusion.org/Configuration)
- [Fedora Third Party Repositories](https://docs.fedoraproject.org/en-US/workstation-working-group/third-party-repos/)

## License

MIT

## Author

Your Name
