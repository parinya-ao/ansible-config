# SPDX-License-Identifier: MIT-0
# =============================================================================
# power Role - TLP Power Management
# =============================================================================

## Overview

Installs and configures [TLP](https://linrunner.de/tlp/) for advanced power management on Fedora workstations. TLP provides significant battery life improvements compared to the default `power-profiles-daemon`.

> **Important:** TLP conflicts with `power-profiles-daemon`. This role automatically disables and masks the default daemon before installing TLP.

## What It Does

| Task | Description |
|------|-------------|
| **Disable PPD** | Stops, disables, and masks `power-profiles-daemon` |
| **Install TLP** | Installs `tlp`, `tlp-pd`, and `tlp-rdw` packages |
| **Configure Services** | Enables TLP services, masks conflicting systemd-rfkill |
| **SELinux Fix** | Sets `tlp_can_write_to_d` boolean for Fedora 38+ compatibility |
| **Apply Config** | Deploys optimized `/etc/tlp.conf` from template |

## Prerequisites

- Fedora Workstation 38+
- `sudo` privileges
- TLP 1.9+ (available in Fedora repositories)

## Role Variables

### Main Toggle

```yaml
power_install_tlp: false  # Set to true to enable TLP installation
```

### CPU Settings

```yaml
# CPU frequency scaling governor
power_cpu_scaling_governor_on_ac: performance   # AC power: max performance
power_cpu_scaling_governor_on_bat: powersave   # Battery: power saving

# CPU energy/performance policy
power_cpu_energy_perf_policy_on_ac: performance
power_cpu_energy_perf_policy_on_bat: power

# CPU boost (Intel/AMD)
power_cpu_boost_on_ac: 1    # Enable on AC
power_cpu_boost_on_bat: 0   # Disable on battery
```

### Battery Charge Thresholds

```yaml
# Protect battery health by limiting charge range
# Supported: ThinkPad, select Dell/Lenovo laptops
power_start_charge_thresh_bat0: 20   # Start charging at 20%
power_stop_charge_thresh_bat0: 80    # Stop at 80% (set to 0 to disable)
```

### Disk Power Management

```yaml
power_disk_apm_level_on_ac: "254 254"   # Max performance on AC
power_disk_apm_level_on_bat: "128 128"  # Medium power saving on battery
```

### Wireless & Connectivity

```yaml
# WiFi power saving
power_wifi_pwr_on_ac: off
power_wifi_pwr_on_bat: on

# Radio device switch
power_wifi_power_on_ac: on
power_wifi_power_on_bat: on
power_bluetooth_power_on_ac: on
power_bluetooth_power_on_bat: off
```

### PCIe & USB

```yaml
# PCIe Active State Power Management
power_pcie_aspm_on_ac: default
power_pcie_aspm_on_bat: powersupersave

# USB auto-suspension
power_usb_autosuspend: 1
power_usb_blacklist: ""  # Devices to exclude (e.g., "1-1:1-2")
```

## Usage

### Enable in Playbook

```yaml
# playbook.yaml
- hosts: localhost
  roles:
    - role: power
      vars:
        power_install_tlp: true
```

### Run with Tag

```bash
# Run only power configuration
ansible-playbook playbook.yaml -i inventory.ini --tags power

# Enable via command-line override
ansible-playbook playbook.yaml -i inventory.ini -e "power_install_tlp=true"
```

## Post-Installation Verification

After running the role, verify TLP is working:

```bash
# Check TLP status
sudo tlp-stat -s

# View battery info and recommendations
sudo tlp-stat -b

# Apply configuration immediately
sudo tlp start
```

## Troubleshooting

### SELinux Issues

On Fedora 38+, TLP requires SELinux permission to write to `/proc/sys/`. This role automatically sets:

```bash
sudo setsebool -P tlp_can_write_to_d 1
```

If you still have issues, check for denials:

```bash
sudo ausearch -m avc -ts recent | grep tlp
```

### Battery Charge Thresholds Not Working

- **ThinkPad**: Install `tp_smapi` or `acpi_call` kernel module
- **Other laptops**: Check if your hardware supports charge thresholds

```bash
# For ThinkPad
sudo dnf install akmod-tp_smapi
```

### Profile Not Switching on AC/Battery

1. Verify TLP services are running:
   ```bash
   systemctl status tlp.service tlp-pd.service
   ```

2. Check for conflicting tools:
   ```bash
   # Remove if installed
   sudo dnf remove power-profiles-daemon
   ```

## Comparison: TLP vs power-profiles-daemon

| Feature | TLP | power-profiles-daemon |
|---------|-----|----------------------|
| **Battery Life** | Excellent (2-4hr improvement) | Moderate |
| **Customization** | Granular control | 3 presets only |
| **SELinux** | Needs configuration | No issues |
| **Laptop Support** | Broad (ThinkPad, Dell, Framework) | Generic |

## References

- [TLP Installation (Fedora)](https://linrunner.de/tlp/installation/fedora.html)
- [TLP Configuration Guide](https://linrunner.de/tlp/settings/tlp.conf.html)
- [Fedora Discussion: TLP Status](https://discussion.fedoraproject.org/t/current-status-of-tlp-on-f40/125643)
- [Framework Community: TLP Results](https://www.reddit.com/r/framework/comments/1m718g5/i_improved_the_battery_life_of_my_13_running/)

## License

MIT-0
