# Power Management Configuration for Fedora Workstation

## Overview

The power role now supports two power management modes:
1. **power-profiles-daemon** (Default, Recommended for Fedora Workstation)
2. **TLP** (Advanced users only)

Plus additional power optimization tools:
- **thermald** - Intel CPU thermal management
- **powertop** - Power monitoring and tuning

## Default Configuration (Recommended)

The default configuration is optimized for Fedora Workstation with Intel processors:

```yaml
power_management_mode: "power-profiles-daemon"  # Default
power_install_thermald: true
power_install_powertop: true
power_powertop_auto_tune: true
```

### What Gets Installed

1. **power-profiles-daemon** - Integrated with GNOME/KDE power settings
2. **thermald** - Prevents Intel CPU overheating
3. **powertop** - Power monitoring with auto-tune service

## Quick Start

### Run with Default Settings (Recommended)

```bash
cd /home/parinya/ansible-config

# Install power management (power-profiles-daemon + thermald + powertop)
ansible-playbook playbook.yaml --tags power
```

### Verify Installation

```bash
# Check power profiles
powerprofilesctl

# Check thermald status
systemctl status thermald

# Check powertop service
systemctl status powertop.service

# Monitor power usage
sudo powertop
```

## Power Management Modes

### Mode 1: power-profiles-daemon (Recommended)

**Best for:** Most Fedora Workstation users

**Pros:**
- ✅ Integrated with GNOME Settings
- ✅ Simple and stable
- ✅ Easy to switch profiles
- ✅ No configuration needed

**Cons:**
- ❌ Less fine-grained control
- ❌ Fewer optimization options

**Usage:**
```bash
# Change power profile
powerprofilesctl set balanced        # Default
powerprofilesctl set power-saver     # Save battery
powerprofilesctl set performance     # Maximum performance

# View current profile
powerprofilesctl
```

### Mode 2: TLP (Advanced)

**Best for:** Advanced users who need maximum battery life

**Pros:**
- ✅ Extensive configuration options
- ✅ Better battery life (when tuned properly)
- ✅ Automatic power savings

**Cons:**
- ❌ Disables GNOME power settings
- ❌ Complex configuration
- ❌ Can cause issues if misconfigured

**Enable TLP mode:**
```yaml
# In playbook.yaml or via extra-vars
power_management_mode: "tlp"
power_install_tlp: true
```

**Usage:**
```bash
# Check TLP status
tlp-stat -s

# View battery info
tlp-stat -b

# Apply TLP settings
sudo tlp start
```

## Components

### 1. power-profiles-daemon

**Package:** `power-profiles-daemon`

**Service:** `power-profiles-daemon.service`

**Configuration:**
```yaml
power_profile_on_ac: "balanced"
power_profile_on_battery: "power-saver"
```

**Commands:**
```bash
# List available profiles
powerprofilesctl

# Set profile
powerprofilesctl set power-saver

# Check current profile
powerprofilesctl | grep "Active Profile"
```

### 2. thermald (Intel CPU Thermal Management)

**Package:** `thermald`

**Service:** `thermald.service`

**Purpose:**
- Prevents CPU overheating
- Manages thermal throttling
- Improves power efficiency
- Essential for Intel 12th/13th gen CPUs

**Verification:**
```bash
# Check status
systemctl status thermald

# View logs
journalctl -u thermald -f

# Check temperature sensors
sensors
```

### 3. powertop (Power Monitoring)

**Package:** `powertop`

**Service:** `powertop.service` (auto-tune)

**Features:**
- Real-time power consumption monitoring
- Device power state analysis
- Automatic power optimization
- Tunable parameters

**Commands:**
```bash
# Interactive mode
sudo powertop

# Apply all optimizations
sudo powertop --auto-tune

# Generate HTML report
sudo powertop --html=report.html

# Check tunables
sudo powertop  # Go to "Tunables" tab
```

**Note:** You may see warnings like:
- `modprobe cpufreq_stats failed` - Normal on newer kernels
- `glob returned GLOB_ABORTED` - Normal on Fedora 38+

These don't affect functionality.

## Configuration Options

### Global Settings

```yaml
# Power management mode
power_management_mode: "power-profiles-daemon"  # or "tlp"

# Component installation
power_install_thermald: true
power_install_powertop: true
power_powertop_auto_tune: true

# TLP settings (only if mode is "tlp")
power_install_tlp: false
```

### TLP-Specific Settings

```yaml
# CPU scaling
power_cpu_scaling_governor_on_ac: performance
power_cpu_scaling_governor_on_bat: powersave

# CPU boost
power_cpu_boost_on_ac: 1
power_cpu_boost_on_bat: 0

# Battery thresholds (Supported laptops)
power_start_charge_thresh_bat0: 20  # Start charging at 20%
power_stop_charge_thresh_bat0: 80   # Stop charging at 80%

# WiFi power saving
power_wifi_pwr_on_ac: "off"
power_wifi_pwr_on_bat: "on"

# PCIe ASPM (critical for laptops)
power_pcie_aspm_on_ac: default
power_pcie_aspm_on_bat: powersupersave
```

## Laptop Optimizations

### power-profiles-daemon Mode (Default)

The default configuration includes:
- ✅ Balanced profile on AC power
- ✅ Power-saver profile on battery
- ✅ thermald for CPU thermal management
- ✅ powertop auto-tune for optimization

### TLP Mode (Advanced)

The TLP configuration includes laptop specific optimizations:
- NVMe power saving
- Intel GPU RC6 power saving
- PCIe ASPM aggressive mode on battery
- USB autosuspend (with audio device blacklist)
- CPU frequency scaling limits on battery
- Battery charge thresholds (20-80%)

## Troubleshooting

### GNOME Power Settings Missing

**Problem:** Power settings disappeared after installing TLP

**Solution:** This is normal. TLP disables power-profiles-daemon.
- Use `tlp-stat -s` to check TLP status
- Or switch back to power-profiles-daemon mode

### powertop Shows "Bad" Tunables

**Problem:** Some tunables still show "Bad" after auto-tune

**Solution:**
```bash
# Run interactive mode
sudo powertop

# Go to "Tunables" tab
# Press Tab to navigate
# Press Space to toggle Bad/Good
```

### Battery Not Charging

**Problem:** Battery stops charging at threshold

**Solution:** This is a feature, not a bug. To disable:
```yaml
power_start_charge_thresh_bat0: 0
power_stop_charge_thresh_bat0: 0
```

### thermald Not Starting

**Problem:** thermald service fails to start

**Solution:**
```bash
# Check if CPU is supported
sudo modprobe intel_pstate

# Check logs
journalctl -u thermald -f

# Restart service
sudo systemctl restart thermald
```

## Verification Checklist

After running the power role:

```bash
# 1. Check power management mode
powerprofilesctl  # Should show profiles (if using power-profiles-daemon)
# OR
tlp-stat -s      # Should show TLP status (if using TLP)

# 2. Check thermald
systemctl status thermald
# Should be "active (running)"

# 3. Check powertop service
systemctl status powertop.service
# Should be "active (exited)" with RemainAfterExit

# 4. Monitor power usage
sudo powertop
# Check "Overview" tab for power consumption

# 5. Check tunables
sudo powertop
# Go to "Tunables" tab - most should be "Good"
```

## Best Practices for Laptops

### Daily Use

1. **Use power-profiles-daemon** (default mode)
2. **Keep thermald running** - Prevents thermal throttling
3. **Run powertop occasionally** - Check for power-hungry apps

### Maximum Battery Life

1. **Use power-saver profile:**
   ```bash
   powerprofilesctl set power-saver
   ```

2. **Reduce screen brightness**
3. **Close unnecessary apps**
4. **Disable Bluetooth** (if not used)
5. **Use Firefox/Chrome power savings**

### Development Work

1. **Use balanced profile:**
   ```bash
   powerprofilesctl set balanced
   ```

2. **Keep thermald active** - Prevents CPU throttling
3. **Monitor with powertop** - Find power-hungry processes

## References

- [Fedora Power Management Guide](https://docs.fedoraproject.org/en-US/quick-docs/power-management/)
- [power-profiles-daemon](https://gitlab.freedesktop.org/hadess/power-profiles-daemon)
- [thermald](https://wiki.debian.org/thermald)
- [powertop](https://wiki.archlinux.org/title/powertop)
- [TLP Documentation](https://linrunner.de/tlp/)

## Related Roles

- `rpmfusion` - Required for some firmware packages
- `firmware` - Installs non-free firmware
- `multimedia` - Intel media drivers (affects power consumption)

---

**Last Updated:** March 21, 2026  
**Tested On:** Intel-based Laptops and Desktops  
**Default Mode:** power-profiles-daemon (Recommended)
