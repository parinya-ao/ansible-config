# Firmware Role

Installs non-free firmware packages on Fedora systems for better hardware compatibility.

## Overview

This role installs firmware packages from both Fedora's official repositories and RPM Fusion's tainted repository, ensuring maximum hardware compatibility for:
- Wi-Fi adapters (Broadcom, Realtek, etc.)
- Graphics cards (NVIDIA, AMD, Intel)
- Bluetooth devices
- Other peripherals requiring proprietary firmware

## Requirements

- Fedora Linux (any supported version)
- Ansible 2.9 or higher
- Root/sudo privileges
- RPM Fusion repositories enabled (handled automatically via role dependency)

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `firmware_install_nonfree` | `true` | Enable non-free firmware installation |
| `firmware_enable_tainted` | `true` | Enable tainted repository for firmware |
| `firmware_install_all_patterns` | `true` | Install all packages matching `*-firmware` pattern |
| `firmware_packages` | (list) | Standard firmware packages to install |
| `firmware_nonfree_packages` | (list) | Non-free firmware release packages |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: local.workstation.firmware
      tags:
        - firmware
        - drivers
```

## Dependencies

This role depends on the `local.workstation.rpmfusion` role, which will be automatically executed if not already run.

## Tags

- `firmware` - Main tag for all firmware tasks
- `standard` - Standard firmware packages
- `tainted` - Tainted/non-free firmware packages
- `wifi` - Wi-Fi firmware packages

## Firmware Packages Installed

### Standard Firmware
- `linux-firmware` - Base Linux firmware
- `amd-ucode-firmware` - AMD microcode
- `intel-audio-firmware` - Intel audio firmware
- `nvidia-gpu-firmware` - NVIDIA GPU firmware
- `rtl8723bs-firmware` - Realtek Wi-Fi firmware
- `rtl8821ce-firmware` - Realtek Wi-Fi firmware

### Non-Free Firmware (from RPM Fusion Tainted)
- All packages matching `*-firmware` pattern
- `broadcom-wl` - Broadcom Wi-Fi driver
- `broadcom-wl-firmware` - Broadcom Wi-Fi firmware

## Verification

After running this role, verify firmware installation:

```bash
# List installed firmware packages
dnf list installed '*firmware*'

# Check for missing firmware
dmesg | grep -i firmware

# Check Wi-Fi firmware
lspci -k | grep -A 3 -i network
```

## Use Cases

### Framework Laptop 13 (Intel)
This role is particularly useful for Framework Laptop 13 with Intel Iris Xe graphics, as it ensures all Wi-Fi and Bluetooth firmware is properly installed.

### Laptops with Hybrid Graphics
For laptops with NVIDIA Optimus or AMD switchable graphics, this role installs the necessary firmware for both GPUs.

## Troubleshooting

### Wi-Fi Not Working After Installation
1. Check if firmware is loaded: `dmesg | grep -i firmware`
2. Reload the Wi-Fi module: `sudo modprobe -r <module> && sudo modprobe <module>`
3. Reboot the system

### Missing Firmware Errors
If you see "firmware not found" errors in `dmesg`, the specific firmware package may not be included. Search for available firmware:
```bash
dnf search firmware | grep <device-name>
```

## References

- [Linux Firmware Project](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/)
- [RPM Fusion Tainted Repository](https://rpmfusion.org/Configuration)
- [Fedora Firmware Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/Firmware/)

## License

MIT

## Author

Your Name
