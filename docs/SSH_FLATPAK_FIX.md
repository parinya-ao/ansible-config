# SSH Permissions and Flatpak Installation Guide

## Problem 1: SSH File Permissions

### The Issue

SSH requires strict file permissions for security. Incorrect permissions will cause SSH to reject keys.

### Required Permissions

| File/Directory | Permission | Octal |
|----------------|------------|-------|
| `~/.ssh/` | drwx------ | 700 |
| `~/.ssh/id_ed25519` (private) | -rw------- | 600 |
| `~/.ssh/id_ed25519.pub` (public) | -rw-r--r-- | 644 |
| `~/.ssh/authorized_keys` | -rw------- | 600 |

### Manual Fix

```bash
# Set directory permissions
chmod 700 ~/.ssh

# Set private key permissions
chmod 600 ~/.ssh/id_ed25519

# Set public key permissions
chmod 644 ~/.ssh/id_ed25519.pub

# Set authorized_keys permissions
chmod 600 ~/.ssh/authorized_keys

# Verify
ls -la ~/.ssh/
```

### Ansible Fix

```bash
cd /home/parinya/ansible-config
ansible-playbook playbook.yaml --tags ssh
```

### Verification

```bash
# Check permissions
ls -la ~/.ssh/

# Test SSH connection
ssh -T git@github.com
# Expected: "Hi <username>! You've successfully authenticated..."
```

---

## Problem 2: No Flatpak Applications Installed

### The Issue

The Ansible configuration was not installing Flatpak applications because:
1. No Flatpak role existed
2. Flatpak applications need to be explicitly configured

### Solution: New Flatpak Role

The new `flatpak` role:
- Installs Flatpak package
- Enables Flathub repository
- Installs configured applications
- Updates applications automatically

### Install Popular Applications

#### Option 1: Run Full Playbook

```bash
cd /home/parinya/ansible-config
ansible-playbook playbook.yaml --tags flatpak
```

#### Option 2: Manual Installation

```bash
# Install Flatpak
sudo dnf install flatpak flatpak-selinux

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install flathub org.signal.Signal
flatpak install flathub org.videolan.VLC
flatpak install flathub md.obs.Studio
```

### Default Applications

The following applications are **configured but disabled by default**:

| Application | Flatpak ID | Enable |
|-------------|------------|--------|
| Signal | `org.signal.Signal` | ✅ Enabled |
| VLC | `org.videolan.VLC` | ✅ Enabled |
| OBS Studio | `md.obs.Studio` | ✅ Enabled |
| LibreOffice | `org.libreoffice.LibreOffice` | ❌ Disabled |
| GIMP | `org.gimp.GIMP` | ❌ Disabled |
| Chromium | `org.chromium.Chromium` | ❌ Disabled |

### Enable Applications

Edit `collections/ansible_collections/local/workstation/roles/flatpak/defaults/main.yml`:

```yaml
flatpak_apps:
  - name: org.signal.Signal
    enabled: true  # Change to true
  
  - name: org.videolan.VLC
    enabled: true  # Change to true
  
  - name: md.obs.Studio
    enabled: true  # Change to true
  
  - name: org.libreoffice.LibreOffice
    enabled: true  # Change to true (if needed)
  
  - name: org.gimp.GIMP
    enabled: true  # Change to true (if needed)
```

### Verification

```bash
# List installed Flatpak applications
flatpak list

# Check applications in menu
# (Log out and log back in if applications don't appear)

# Update all Flatpak applications
flatpak update
```

---

## Complete Installation Commands

### Run Everything

```bash
cd /home/parinya/ansible-config

# Install everything (Intel firmware, Ghostty, SSH, Flatpak apps)
ansible-playbook playbook.yaml

# Or run specific tags
ansible-playbook playbook.yaml --tags ssh,flatpak
ansible-playbook playbook.yaml --tags rpmfusion,firmware,multimedia
ansible-playbook playbook.yaml --tags ghostty
```

### Individual Components

```bash
# SSH permissions only
ansible-playbook playbook.yaml --tags ssh

# Flatpak applications only
ansible-playbook playbook.yaml --tags flatpak

# Intel firmware and drivers
ansible-playbook playbook.yaml --tags rpmfusion,firmware,multimedia

# Ghostty terminal
ansible-playbook playbook.yaml --tags ghostty
```

---

## Troubleshooting

### SSH Still Not Working

1. **Check ownership:**
   ```bash
   chown -R $USER:$USER ~/.ssh/
   ```

2. **Check SELinux:**
   ```bash
   restorecon -Rv ~/.ssh/
   ```

3. **Test with verbose output:**
   ```bash
   ssh -v git@github.com
   ```

### Flatpak Applications Not in Menu

1. **Refresh desktop database:**
   ```bash
   update-desktop-database ~/.local/share/applications
   ```

2. **Log out and log back in**

3. **Check installation:**
   ```bash
   flatpak list --app
   ```

### Flatpak Installation Fails

1. **Check disk space:**
   ```bash
   df -h
   ```

2. **Repair Flatpak:**
   ```bash
   sudo flatpak repair --system
   ```

3. **Check Flathub connectivity:**
   ```bash
   curl -I https://flathub.org
   ```

---

## Quick Reference

### SSH Commands

```bash
# Set permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/authorized_keys

# Test connection
ssh -T git@github.com

# Generate new key (if needed)
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Flatpak Commands

```bash
# List applications
flatpak list

# Install application
flatpak install flathub <app-id>

# Remove application
flatpak uninstall <app-id>

# Update all
flatpak update

# Remove unused runtimes
flatpak uninstall --unused

# Search
flatpak search <name>
```

---

## References

- [SSH Best Practices](https://www.ssh.com/academy/ssh/best-practices)
- [Flatpak Documentation](https://docs.flatpak.org/)
- [Flathub](https://flathub.org/)
- [Fedora Flatpak Guide](https://docs.fedoraproject.org/en-US/quick-docs/flatpak/)
