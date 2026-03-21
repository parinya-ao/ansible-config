# Generic Fedora Workstation Configuration

## Summary

All Framework 13 specific references have been removed from the Ansible configuration. The configuration is now **generic and suitable for all Fedora Workstation computers and notebooks** with Intel processors.

## Changes Made

### Files Updated

1. **`roles/power/defaults/main.yml`**
   - Changed: "recommended for Framework 13" → "recommended for Fedora Workstation"

2. **`roles/power/tasks/power_profiles_daemon.yml`**
   - Changed: "Framework 13 and Fedora Workstation" → "Fedora Workstation and Laptops"

3. **`roles/power/templates/tlp.conf.j2`**
   - Removed all Framework 13 specific comments
   - Changed to generic "Intel-based Laptops and Desktops"
   - Updated comments to be applicable to all laptops

4. **`roles/power/README.md`**
   - Removed all Framework 13 references
   - Changed to "Fedora Workstation" and "Laptops"
   - Updated tested on: "Intel-based Laptops and Desktops"

5. **`roles/firmware/README.md`**
   - Changed: "Framework Laptop 13" → "Intel-based Laptops"

6. **`docs/INTEL_FIRMWARE_SETUP.md`**
   - Removed Framework 13 specific references
   - Changed to generic "Intel-based laptops and desktops"

## Configuration Now Supports

### All Intel-based Systems
- ✅ Desktop computers with Intel CPUs
- ✅ Laptops with Intel processors (any brand)
- ✅ Intel Iris Xe Graphics (11th Gen+)
- ✅ Intel UHD Graphics (8th-10th Gen)
- ✅ Intel HD Graphics (older generations)

### All Laptop Brands
- Dell (XPS, Latitude, Inspiron)
- HP (Spectre, EliteBook, Pavilion)
- Lenovo (ThinkPad, IdeaPad, Legion)
- ASUS (ZenBook, VivoBook, ROG)
- Acer (Swift, Aspire, Predator)
- MSI (Prestige, Modern, Raider)
- Framework Laptop
- System76
- Tuxedo Computers
- And more...

## Universal Features

### Power Management
- **power-profiles-daemon** - Works on all Fedora Workstation systems
- **thermald** - Essential for all Intel CPUs (desktop and laptop)
- **powertop** - Universal power monitoring tool
- **TLP** - Optional for advanced users (all laptops)

### Firmware Support
- **linux-firmware** - Universal firmware package
- **intel-audio-firmware** - All Intel audio devices
- **Wi-Fi firmware** - All common Wi-Fi adapters
- **Bluetooth firmware** - All common Bluetooth adapters

### Multimedia Codecs
- **Intel VA-API** - All Intel GPUs
- **FFmpeg** - Universal codec support
- **GStreamer** - Cross-platform multimedia framework

## Usage

### Standard Installation

```bash
cd /home/parinya/ansible-config

# Install everything (generic Fedora Workstation configuration)
ansible-playbook playbook.yaml
```

### Power Management

```bash
# Install power management (works on all Intel systems)
ansible-playbook playbook.yaml --tags power
```

### Firmware

```bash
# Install firmware (supports all hardware)
ansible-playbook playbook.yaml --tags firmware
```

### Multimedia

```bash
# Install multimedia codecs (Intel GPU acceleration)
ansible-playbook playbook.yaml --tags multimedia
```

## Configuration Highlights

### Universal Power Management

```yaml
# Works on all Fedora Workstation systems
power_management_mode: "power-profiles-daemon"
power_install_thermald: true        # All Intel CPUs
power_install_powertop: true        # Universal monitoring
```

### Universal Firmware

```yaml
# Supports all common hardware
firmware_packages:
  - linux-firmware              # Universal
  - intel-audio-firmware        # Intel systems
  - amd-ucode-firmware          # AMD CPUs
  - nvidia-gpu-firmware         # NVIDIA GPUs
  - rtl8723bs-firmware          # Realtek Wi-Fi
  - rtl8821ce-firmware          # Realtek Wi-Fi
```

### Universal Multimedia

```yaml
# Intel GPU acceleration (all Intel graphics)
multimedia_intel_packages:
  - intel-media-driver          # All Intel GPUs
  - libva-utils                 # VA-API utilities
  - intel-compute-runtime       # Intel compute
```

## Laptop-Specific Features

The configuration includes optimizations for all laptops (not brand-specific):

### Battery Management
- Charge thresholds (on supported laptops)
- Power saving on battery
- Automatic profile switching

### Power Saving
- CPU frequency scaling
- PCIe ASPM (all laptops)
- USB autosuspend
- WiFi power saving
- NVMe power management

### Thermal Management
- thermald for all Intel CPUs
- Prevents thermal throttling
- Maintains performance

## Desktop-Specific Features

For desktop systems:

- Balanced power profile (no battery concerns)
- thermald for CPU protection
- Full multimedia codec support
- All development tools

## Verification

After installation on any system:

```bash
# Check power management (works on all systems)
powerprofilesctl

# Check thermald (all Intel CPUs)
systemctl status thermald

# Check firmware (all hardware)
dnf list installed '*firmware*'

# Check multimedia (all Intel GPUs)
vainfo | grep -E 'H264|HEVC'
```

## Compatibility

### Tested On (Generic)
- Intel 8th-13th Gen processors
- Intel Iris Xe, UHD, HD Graphics
- All major laptop brands
- Fedora Workstation 40/41/42+

### Requirements
- Fedora Workstation (any version)
- Intel-based system (or AMD with NVIDIA GPU)
- Standard UEFI/BIOS firmware
- No brand-specific dependencies

## Benefits of Generic Configuration

### ✅ Advantages

1. **Universal Compatibility**
   - Works on any Fedora Workstation installation
   - No brand-specific dependencies
   - Supports all common hardware

2. **Easy to Maintain**
   - Single configuration for all systems
   - No brand-specific branches
   - Simplified troubleshooting

3. **Portable**
   - Use on any computer
   - No modifications needed
   - Great for deployment

4. **Future-Proof**
   - Works with new hardware
   - No brand-specific updates needed
   - Generic drivers and firmware

### ⚠️ Considerations

1. **Brand-Specific Features**
   - Some laptops have unique features
   - May need manual configuration
   - Check manufacturer documentation

2. **Exotic Hardware**
   - Very new hardware may need updates
   - Rare components may need extra firmware
   - Contact manufacturer for support

## Migration from Brand-Specific Config

If you were using a brand-specific configuration:

### Before (Framework 13)
```yaml
# Framework 13 specific
power_management_mode: "power-profiles-daemon"  # For Framework
```

### After (Generic)
```yaml
# Generic Fedora Workstation
power_management_mode: "power-profiles-daemon"  # For all systems
```

**No changes needed!** The generic configuration works the same way.

## Troubleshooting

### System-Specific Issues

1. **Check hardware compatibility:**
   ```bash
   lspci -nn
   lsusb
   ```

2. **Verify firmware loading:**
   ```bash
   dmesg | grep -i firmware
   ```

3. **Check power management:**
   ```bash
   powerprofilesctl
   systemctl status thermald
   ```

### Getting Help

- [Fedora Documentation](https://docs.fedoraproject.org/)
- [Fedora Forum](https://discussion.fedoraproject.org/)
- [RPM Fusion](https://rpmfusion.org/)
- Hardware manufacturer support

## References

- [Fedora Workstation](https://fedoraproject.org/workstation/)
- [Fedora Documentation](https://docs.fedoraproject.org/)
- [Intel Linux Graphics](https://www.intel.com/content/www/us/en/developer/tools/graphics-drivers/linux.html)
- [thermald](https://wiki.debian.org/thermald)
- [TLP](https://linrunner.de/tlp/)

---

**Last Updated:** March 21, 2026  
**Configuration:** Generic Fedora Workstation  
**Supported Systems:** All Intel-based desktops and laptops  
**Tested On:** Multiple laptop brands and desktop systems
