# Distrobox Installation Guide

## Overview

Distrobox is now included in the base system packages installed by the common role.

## What is Distrobox?

Distrobox is a tool that allows you to create and manage Linux containers with seamless integration with your host system. It provides:

- **Any distribution** - Run any Linux distro inside your Fedora system
- **Seamless integration** - Access home directory, USB devices, GPUs, and more
- **CLI focused** - Simple command-line interface
- **Podman/Docker backend** - Uses your preferred container runtime

## Installation

### Via Ansible (Automatic)

Distrobox is now automatically installed when you run the common role:

```bash
cd /home/parinya/ansible-config

# Install common role (includes distrobox)
ansible-playbook playbook.yaml --tags common

# Or install everything
ansible-playbook playbook.yaml
```

### Manual Installation

```bash
# Install distrobox
sudo dnf install distrobox

# Verify installation
distrobox --version
```

## Quick Start

### Create Your First Container

```bash
# Create an Ubuntu container
distrobox create -n ubuntu -i ubuntu:latest

# Enter the container
distrobox enter ubuntu

# Exit the container
exit
```

### Popular Distributions

```bash
# Ubuntu
distrobox create -n ubuntu -i ubuntu:latest

# Debian
distrobox create -n debian -i debian:stable

# Arch Linux
distrobox create -n arch -i archlinux:latest

# Alpine
distrobox create -n alpine -i alpine:latest

# openSUSE
distrobox create -n opensuse -i opensuse/tumbleweed
```

## Common Commands

```bash
# List containers
distrobox list

# Create container
distrobox create -n <name> -i <image>

# Enter container
distrobox enter <name>

# Stop container
distrobox stop <name>

# Start container
distrobox start <name>

# Delete container
distrobox rm <name>

# Export container to image
distrobox export -n <name> -o <output-image>

# Import from image
distrobox import -i <image> -n <name>
```

## Use Cases

### 1. Development Environment

```bash
# Create isolated development environment
distrobox create -n dev -i fedora:latest

# Install development tools inside container
distrobox enter dev
sudo dnf install gcc gcc-c++ make cmake git
```

### 2. Testing Across Distributions

```bash
# Test on multiple distributions
distrobox create -n ubuntu-test -i ubuntu:22.04
distrobox create -n debian-test -i debian:12
distrobox create -n arch-test -i archlinux:latest
```

### 3. Running Legacy Applications

```bash
# Create container with older libraries
distrobox create -n legacy -i ubuntu:18.04

# Install and run legacy software
distrobox enter legacy
sudo apt install legacy-app
legacy-app
```

### 4. Security Testing

```bash
# Isolated security testing environment
distrobox create -n security -i kalilinux/kali-rolling
distrobox enter security
```

## Features

### Home Directory Integration

Your home directory is automatically mounted in the container:

```bash
distrobox enter ubuntu
ls ~  # Shows your host home directory
```

### Application Export

Export applications from container to host menu:

```bash
# Export an application
distrobox-export --app /usr/bin/gimp

# Remove exported application
distrobox-export --app /usr/bin/gimp --uninstall
```

### GPU Acceleration

GPU is automatically available in containers:

```bash
distrobox create -n ml -i ubuntu:latest
distrobox enter ml
# GPU devices are available
ls /dev/nvidia*
```

### USB Device Access

USB devices can be passed through to containers:

```bash
distrobox enter --additional-flags "--device /dev/ttyUSB0" ubuntu
```

## Configuration

### Default Images

Create `~/.config/distrobox/distrobox.conf`:

```ini
# Default image for new containers
default_image="fedora:latest"

# Additional flags
additional_flags="--volume /data:/data"
```

### Custom Container Names

```bash
# Use meaningful names
distrobox create -n web-dev -i node:18
distrobox create -n python-dev -i python:3.11
distrobox create -n rust-dev -i rust:latest
```

## Integration with Host

### Access Host Commands

Run host commands from inside container:

```bash
distrobox enter ubuntu
host-cmd flatpak list
host-cmd dnf info firefox
```

### Share Directories

```bash
# Create container with additional shared directory
distrobox create -n shared \
  -i ubuntu:latest \
  --additional-flags "--volume /mnt/data:/mnt/data"
```

### Systemd Integration

Containers can run systemd:

```bash
distrobox create -n systemd-test \
  -i fedora:latest \
  --init-system systemd

distrobox enter systemd-test
systemctl status
```

## Troubleshooting

### Container Won't Start

```bash
# Check Podman/Docker status
systemctl status podman
# or
systemctl status docker

# Recreate container
distrobox rm <name>
distrobox create -n <name> -i <image>
```

### Permission Denied

```bash
# Fix Podman permissions
podman system migrate

# Or use rootful container
distrobox create -n <name> -i <image> --root
```

### Network Issues

```bash
# Check network inside container
distrobox enter <name>
ping -c 3 google.com

# Restart container network
distrobox stop <name>
distrobox start <name>
```

### Disk Space

```bash
# Check container size
distrobox list

# Remove unused containers
distrobox rm <name>

# Clean up Podman
podman system prune -a
```

## Best Practices

1. **Use specific versions** - Pin to specific versions for reproducibility
   ```bash
   distrobox create -n python-dev -i python:3.11.5
   ```

2. **Name containers meaningfully** - Use descriptive names
   ```bash
   distrobox create -n web-frontend -i node:18
   ```

3. **Export only needed apps** - Don't export everything
   ```bash
   distrobox-export --app /usr/bin/code
   ```

4. **Regular cleanup** - Remove unused containers
   ```bash
   distrobox rm old-container
   ```

5. **Backup important containers** - Export before major changes
   ```bash
   distrobox export -n important -o backup-image
   ```

## Resources

- [Distrobox Official Documentation](https://distrobox.privatedns.org/)
- [Distrobox GitHub](https://github.com/89luca89/distrobox)
- [Podman Documentation](https://podman.io/)
- [Fedora Container Tools](https://docs.fedoraproject.org/en-US/fedora/latest/system-administrators-guide/containers/)

## Related Packages

Distrobox works well with these tools (already installed or available):

- **Podman** - Container runtime (installed by default on Fedora)
- **Toolbox** - Similar tool by Fedora
- **Flatpak** - Sandboxed applications
- **Docker** - Alternative container runtime

## Verification

After Ansible installation:

```bash
# Check if distrobox is installed
distrobox --version

# List available containers (should be empty initially)
distrobox list

# Create test container
distrobox create -n test -i fedora:latest
distrobox list
distrobox rm test
```

---

**Added to Ansible:** March 21, 2026  
**Package:** distrobox  
**Role:** local.workstation.common  
**Category:** Base system packages
