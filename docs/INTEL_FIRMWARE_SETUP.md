# Intel Firmware and Driver Installation Guide

This document describes the automated installation of Intel firmware, drivers, and multimedia codecs using Ansible.

## Overview

This Ansible configuration automates the installation of:
- **RPM Fusion Repositories** (Free and Non-Free)
- **Non-Free Firmware** (including Intel firmware)
- **Intel Media Drivers** (VA-API for H.264/H.265 hardware acceleration)
- **Multimedia Codecs** (FFmpeg, GStreamer plugins)
- **OpenH264 Support** (for Firefox/browser video playback)

## Hardware Support

This configuration is tested and optimized for:
- **Intel Iris Xe Graphics** (11th Gen and newer)
- **Intel UHD Graphics** (8th-10th Gen)
- **Intel HD Graphics** (older generations)
- Framework Laptop 13 with Intel processors

## Quick Start

### Run the Complete Setup

```bash
# Navigate to the ansible-config directory
cd /home/parinya/ansible-config

# Run the playbook with all roles
ansible-playbook playbook.yaml

# Or run with specific tags
ansible-playbook playbook.yaml --tags rpmfusion,firmware,multimedia
```

### Run Specific Roles

```bash
# Only RPM Fusion repositories
ansible-playbook playbook.yaml --tags rpmfusion

# Only firmware installation
ansible-playbook playbook.yaml --tags firmware

# Only multimedia codecs and Intel drivers
ansible-playbook playbook.yaml --tags multimedia
```

## What Gets Installed

### 1. RPM Fusion Repositories

```yaml
- RPM Fusion Free Repository
- RPM Fusion Non-Free Repository
- Tainted Firmware Repository
- AppStream Metadata (for GNOME Software integration)
```

### 2. Firmware Packages

```yaml
Standard Firmware:
  - linux-firmware
  - amd-ucode-firmware
  - intel-audio-firmware
  - nvidia-gpu-firmware
  - rtl8723bs-firmware
  - rtl8821ce-firmware

Non-Free Firmware (from RPM Fusion Tainted):
  - All *-firmware packages
  - broadcom-wl
  - broadcom-wl-firmware
```

### 3. Intel Media Drivers

```yaml
Intel VA-API Drivers:
  - intel-media-driver      # Main Intel media driver
  - libva-utils             # VA-API utilities
  - intel-compute-runtime   # Intel compute runtime (OpenCL)
```

### 4. Multimedia Codecs

```yaml
Core Codecs:
  - ffmpeg                  # Full FFmpeg with codec support
  - ffmpeg-libs             # FFmpeg libraries
  - libva                   # Video Acceleration API
  - libva-utils             # VA-API utilities

GStreamer Plugins:
  - gstreamer1-plugins-base
  - gstreamer1-plugins-good
  - gstreamer1-plugins-ugly
  - gstreamer1-plugins-bad-free
  - gstreamer1-libav

OpenH264 (Browser Support):
  - openh264
  - gstreamer1-plugin-openh264
  - mozilla-openh264
```

## Verification

### 1. Verify RPM Fusion Repositories

```bash
dnf repolist | grep rpmfusion
```

Expected output:
```
rpmfusion-free
rpmfusion-free-updates
rpmfusion-nonfree
rpmfusion-nonfree-updates
rpmfusion-nonfree-steam
```

### 2. Verify Firmware Installation

```bash
# List installed firmware packages
dnf list installed '*firmware*'

# Check for firmware loading errors
dmesg | grep -i firmware
```

### 3. Verify Intel VA-API (Hardware Acceleration)

```bash
# Check VA-API status
vainfo

# Or with DRM display (recommended for modern systems)
vainfo --display drm
```

Expected output for Intel Iris Xe:
```
libva info: VA-API version 1.19.0
libva info: User environment variable LIBVA_DRIVER_NAME set to 'iHD'
libva info: Trying to open /usr/lib64/dri/i965_drv_video.so
libva info: Found init function __vaDriverInit_1_1
libva info: va_openDriver() returns 0
vainfo: VA-API version: 1.19 (libva 2.19.0)
vainfo: Driver version: Intel i965 driver for Intel(R) Tiger Lake - 2.4.1
...
  VAProfileH264Main               : VAEntrypointVLD
  VAProfileH264High               : VAEntrypointVLD
  VAProfileHEVCMain               : VAEntrypointVLD
  VAProfileHEVCMain10             : VAEntrypointVLD
```

**Key profiles to look for:**
- `VAProfileH264` - H.264/AVC decoding
- `VAProfileHEVC` - H.265/HEVC decoding

### 4. Verify FFmpeg Installation

```bash
# Check FFmpeg version and codecs
ffmpeg -version

# List available decoders
ffmpeg -decoders | grep -E 'h264|hevc'
```

### 5. Verify OpenH264 (Browser Support)

```bash
# Check OpenH264 plugin
rpm -qa | grep openh264
```

## Manual Installation (Without Ansible)

If you prefer to install manually without Ansible:

### Step 1: Enable RPM Fusion

```bash
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Step 2: Install Non-Free Firmware

```bash
sudo dnf install rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
```

### Step 3: Install Intel Media Drivers

```bash
sudo dnf install intel-media-driver libva-utils intel-compute-runtime
```

### Step 4: Install Multimedia Codecs

```bash
# Swap to full FFmpeg
sudo dnf swap ffmpeg-free ffmpeg --allowerasing

# Install codec packages
sudo dnf groupupdate multimedia --setopt="install_weak_deps=False" \
  --exclude=PackageKit-gstreamer-plugin
```

### Step 5: Enable OpenH264

```bash
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf install gstreamer1-plugin-openh264 mozilla-openh264
```

### Step 6: Verify Installation

```bash
vainfo | grep -E 'H264|HEVC'
```

## Troubleshooting

### VA-API Not Working

1. **Check if Intel driver is installed:**
   ```bash
   rpm -qa | grep intel-media-driver
   ```

2. **Check LIBVA_DRIVER_NAME:**
   ```bash
   echo $LIBVA_DRIVER_NAME
   # Should be empty or 'iHD' for modern Intel GPUs
   ```

3. **Try forcing iHD driver:**
   ```bash
   export LIBVA_DRIVER_NAME=iHD
   vainfo
   ```

### Video Still Stuttering

1. **Check if hardware acceleration is being used:**
   ```bash
   sudo dnf install intel-gpu-tools
   sudo intel_gpu_top
   ```

2. **Verify video player supports VA-API:**
   - VLC: Tools → Preferences → Input/Codecs → Hardware-accelerated decoding
   - Firefox: `about:support` → Check "Compositing" and "Hardware Acceleration"

### Firefox Not Playing H.264 Videos

1. **Check OpenH264 plugin:**
   ```bash
   about:plugins
   ```

2. **Enable hardware decoding in Firefox:**
   ```
   about:config
   media.ffvpx.enabled = false
   media.rdd-vaapi.enabled = true
   ```

## Configuration Variables

You can customize the installation by modifying these variables:

### RPM Fusion Role

```yaml
rpmfusion_enable_free: true           # Enable Free repository
rpmfusion_enable_nonfree: true        # Enable Non-Free repository
rpmfusion_install_tainted: true       # Install tainted firmware
rpmfusion_install_appstream: true     # Install AppStream metadata
```

### Firmware Role

```yaml
firmware_install_nonfree: true        # Install non-free firmware
firmware_enable_tainted: true         # Enable tainted repository
firmware_install_all_patterns: true   # Install all *-firmware packages
```

### Multimedia Role

```yaml
multimedia_install_codecs: true              # Install multimedia codecs
multimedia_install_video_acceleration: true  # Install VA-API drivers
multimedia_install_openh264: true            # Install OpenH264
multimedia_gpu_vendor: "intel"               # Set to "intel", "amd", or "nvidia"
multimedia_auto_detect_gpu: true             # Auto-detect GPU vendor
```

## References

- [RPM Fusion Official Site](https://rpmfusion.org/)
- [Intel Media Driver GitHub](https://github.com/intel/media-driver)
- [VA-API Documentation](https://www.freedesktop.org/wiki/Software/vaapi/)
- [Fedora Multimedia Wiki](https://fedoraproject.org/wiki/Multimedia)
- [Framework Laptop 13 Linux Guide](https://frame.work/docs/linux)

## License

MIT
