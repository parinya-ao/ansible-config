# Kernel LTS Migration - Integration Guide

## Overview

This document describes the complete kernel-longterm-6.12 migration setup for Fedora 43, including:

1. **Kernel Role**: Reusable Ansible role with complete kernel LTS migration logic
2. **Example Playbook**: `kernel_lts_migration.yml` - Standalone migration playbook
3. **Integration Options**: How to use in your existing playbooks

---

## File Structure

```
ansible-config/
├── kernel_lts_migration.yml          # Standalone migration playbook
├── roles/
│   └── kernel/                       # Kernel LTS migration role
│       ├── README.md                 # Comprehensive role documentation
│       ├── defaults/main.yml         # Default variables
│       ├── handlers/main.yml         # Reboot handler
│       ├── meta/main.yml             # Role metadata
│       ├── tasks/main.yml            # 9-step migration tasks
│       ├── vars/main.yml             # High-priority variables
│       └── tests/
│           ├── inventory             # Test inventory
│           └── test.yml              # Test playbook
└── playbook.yaml                     # Main playbook (can include kernel role)
```

---

## Quick Start

### Option 1: Use Standalone Playbook

```bash
# Dry run (check mode)
ansible-playbook kernel_lts_migration.yml --check

# Execute with automatic reboot
ansible-playbook kernel_lts_migration.yml -e kernel_auto_reboot=true

# Execute without reboot (manual reboot required later)
ansible-playbook kernel_lts_migration.yml
```

### Option 2: Include in Existing Playbook

Edit your main `playbook.yaml`:

```yaml
---
- hosts: all
  become: true
  roles:
    - common
    - kernel          # Add kernel role after common
    - desktop
    - developer
```

Then run:

```bash
ansible-playbook playbook.yaml -t kernel
```

---

## Migration Workflow

### Step 1: Configure DNF (Automated)
```bash
# /etc/dnf/dnf.conf updated with:
# exclude=kernel,kernel-core,kernel-modules,kernel-modules-extra,kernel-devel,kernel-headers
```

### Step 2: Install Dependencies (Automated)
```bash
dnf install dnf5-plugins-core python3-dnf-plugin-versionlock
```

### Step 3: Enable COPR Repository (Automated)
```bash
dnf copr enable -y kwizart/kernel-longterm-6.12
```

### Step 4: Install LTS Kernel (Automated)
```bash
dnf install kernel-longterm kernel-longterm-core kernel-longterm-modules \
  kernel-longterm-modules-extra kernel-longterm-devel \
  --disableexcludes=main
```

### Step 5: Apply Version Lock (Automated)
```bash
# Dynamic - version detected from installed kernel
dnf versionlock add 'kernel-longterm-<VERSION>-<RELEASE>*'
```

### Step 6: Remove Standard Kernels (Automated)
```bash
rpm -qa 'kernel-[0-9]*' | grep -v 'kernel-longterm' | xargs dnf remove -y
```

### Step 7: Reboot (Manual or Automated)
```bash
reboot  # Or automatic via kernel_auto_reboot: true
```

### Step 8: Verify New Kernel
```bash
uname -r          # Should show kernel-longterm version
grubby --info=ALL # Check GRUB default boot entry
```

---

## Variable Customization

### Essential Variables

| Variable | Default | Use Case |
|----------|---------|----------|
| `kernel_auto_reboot` | `false` | Set to `true` for hands-off automation |
| `kernel_remove_standard_kernels` | `true` | Set to `false` for conservative approach |
| `kernel_exclude_standard` | `true` | Keep as `true` to prevent standard kernels from reinstalling |

### Advanced Variables

```yaml
# Custom COPR repository (if using different LTS version)
kernel_lts_copr_repo: "kwizart/kernel-longterm-6.12"

# Custom reboot message and timeout
kernel_reboot_message: "Custom reboot message"
kernel_reboot_timeout: 900  # 15 minutes

# Disable specific features
kernel_install_lts: false              # Skip LTS installation
kernel_apply_versionlock: false        # Don't apply version lock
kernel_exclude_standard: false         # Don't configure DNF excludes
```

---

## Usage Examples

### Example 1: Basic Migration (No Reboot)

```yaml
---
- name: Migrate to kernel-longterm
  hosts: fedora43_servers
  become: true
  roles:
    - kernel
```

Run:
```bash
ansible-playbook playbook.yml
# Manual reboot required after
```

### Example 2: Complete Automation with Reboot

```yaml
---
- name: Automated kernel migration with reboot
  hosts: fedora43_servers
  become: true
  vars:
    kernel_auto_reboot: true
  roles:
    - kernel
```

Run:
```bash
ansible-playbook playbook.yml
# System automatically reboots
```

### Example 3: Conservative (Keep Standard Kernels)

```yaml
---
- name: Install LTS without removing standard kernels
  hosts: fedora43_servers
  become: true
  vars:
    kernel_remove_standard_kernels: false
  roles:
    - kernel
```

### Example 4: Multi-Stage with Other Roles

```yaml
---
- name: Complete Fedora 43 setup with kernel migration
  hosts: all
  become: true
  roles:
    - common              # Base system setup
    - kernel              # Kernel LTS migration
    - docker              # Docker installation
    - developer           # Developer tools
    - desktop             # Desktop environment
  vars:
    kernel_auto_reboot: false  # Manual reboot after all roles
```

---

## Troubleshooting

### Issue: Fedora 43 Check Fails

**Symptom**: Task fails with "This role is only for Fedora 43"

**Solution**:
```bash
# Check current version
cat /etc/os-release | grep VERSION_ID

# Upgrade if needed
sudo dnf system-upgrade download --releasever=43
sudo dnf system-upgrade reboot
```

### Issue: COPR Repository Not Found

**Symptom**: "Cannot find module" or "Unable to find packages"

**Solution**:
```bash
# Verify COPR is enabled
dnf copr status kwizart/kernel-longterm-6.12

# Re-enable if needed
sudo dnf copr enable -y kwizart/kernel-longterm-6.12

# Refresh metadata
sudo dnf clean all && sudo dnf makecache
```

### Issue: Cannot Install LTS Kernel

**Symptom**: "Package kernel-longterm not found"

**Solution**:
```bash
# Verify kernel packages are available
dnf search kernel-longterm

# Check if COPR repo is properly configured
dnf repolist | grep longterm

# Re-enable COPR
sudo dnf copr enable -y kwizart/kernel-longterm-6.12
```

### Issue: Version Lock Not Applied

**Symptom**: "dnf versionlock" command fails

**Solution**:
```bash
# Verify plugin is installed
dnf list installed | grep versionlock

# Install if missing
sudo dnf install python3-dnf-plugin-versionlock

# Check lock status
dnf versionlock list
```

### Issue: Standard Kernels Won't Remove

**Symptom**: "Package kernel-X.X.X not found for removal"

**Solution**:
```bash
# Check installed kernels
rpm -qa | grep ^kernel

# Verify LTS is installed
rpm -qa | grep kernel-longterm

# Check if it's in use
uname -r

# Boot entry
grubby --info=ALL
```

### Manual Recovery: Remove Version Locks

If you need to downgrade or make changes to versionlock:

```bash
# Remove all version locks
sudo dnf versionlock delete "*"

# Remove specific package lock
sudo dnf versionlock delete "kernel-longterm*"

# Verify removed
sudo dnf versionlock list
```

---

## Verification Commands

### After Migration

```bash
# 1. Check kernel version
uname -r
# Expected output: kernel-longterm (e.g., 6.12.x-longterm-...)

# 2. Check all installed kernels
rpm -qa | grep ^kernel | sort

# 3. Verify version lock
sudo dnf versionlock list

# 4. Check GRUB default
sudo grubby --info=ALL

# 5. Check DNF excludes
grep -A2 "^[[]main]" /etc/dnf/dnf.conf

# 6. Verify COPR is enabled
dnf copr status kwizart/kernel-longterm-6.12
```

---

## Tags Reference

Run specific parts of the role using tags:

```bash
# Run entire role
ansible-playbook playbook.yml -t kernel

# Run only verification
ansible-playbook playbook.yml -t kernel-verify

# Run only installation steps
ansible-playbook playbook.yml -t kernel-install,kernel-copr,kernel-plugins

# Run only cleanup
ansible-playbook playbook.yml -t kernel-cleanup

# Skip reboot
ansible-playbook playbook.yml -t kernel --skip-tags kernel-reboot
```

---

## Scheduling the Migration

### Option 1: Maintenance Window

Plan for a scheduled maintenance window:

```bash
# Send notification 24 hours before
# Schedule playbook run for maintenance window
ansible-playbook kernel_lts_migration.yml -e kernel_auto_reboot=true
```

### Option 2: Rolling Deployment

For multiple servers, use inventory groups:

```yaml
[fedora43_group_1]
server1.example.com

[fedora43_group_2]
server2.example.com
server3.example.com
```

```bash
# Migrate group 1
ansible-playbook playbook.yml -i inventory.ini -l fedora43_group_1

# Wait for verification, then migrate group 2
ansible-playbook playbook.yml -i inventory.ini -l fedora43_group_2
```

---

## Rollback Procedures

If issues occur with the LTS kernel:

### Return to Standard Kernel

```bash
# 1. Boot to standard kernel from GRUB menu
# (Select older kernel entry at boot)

# 2. Remove versionlock
sudo dnf versionlock delete "*"

# 3. Remove LTS kernel
sudo dnf remove kernel-longterm* -y

# 4. Reinstall standard kernels
sudo dnf install kernel -y

# 5. Update GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# 6. Reboot
sudo reboot
```

### Report Issue

Document and report:
- Full error messages
- `uname -r` output
- Hardware configuration
- Package versions installed
- DNF transaction history: `sudo dnf history list`

---

## Best Practices

1. **Always Test First**: Test in development environment before production
2. **Backup GRUB Config**: `sudo cp /etc/default/grub /etc/default/grub.bak`
3. **Verify LTS Package**: `dnf search kernel-longterm` before running role
4. **Schedule Maintenance**: Run during low-traffic periods
5. **Monitor Reboot**: Have console access during reboot if possible
6. **Post-Migration Verification**: Run verification commands after reboot
7. **Document Changes**: Keep audit trail of when migration occurred
8. **Update Monitoring**: Ensure monitoring systems account for new kernel

---

## Support & Documentation

### Role Documentation
- [Kernel Role README](roles/kernel/README.md)

### Fedora Documentation
- [Fedora DNF Documentation](https://docs.fedoraproject.org/en-US/fedora/latest/system-administrators-guide/basic-system-configuration/dnf/)
- [COPR Documentation](https://docs.pagure.org/copr.copr/user_documentation.html)

### Kernel-Longterm COPR
- [kwizart/kernel-longterm-6.12](https://copr.fedorainfracloud.org/coprs/kwizart/kernel-longterm-6.12/)

---

## License

SPDX-License-Identifier: MIT-0
