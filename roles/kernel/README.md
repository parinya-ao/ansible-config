# Kernel LTS Migration Role

This role manages Fedora 43 kernel migration to kernel-longterm-6.12 with version locking and automatic cleanup of standard kernels.

## Features

### 🔒 Safety & Verification

- System Fedora 43 requirement check
- Atomic configuration management using `blockinfile`
- Version detection and dynamic locking

### 📦 Kernel Management

- Automatic installation of kernel-longterm-6.12 from COPR repository
- DNF configuration to prevent standard kernel reinstallation
- Smart cleanup that removes only standard kernels, preserving LTS

### 🔐 Version Locking

- Automatic version lock using `dnf versionlock` plugin
- Prevents accidental kernel downgrades
- Dynamic version detection from installed packages

### 🔄 Optional Reboot

- Configurable automatic reboot support
- Custom reboot messages and timeout settings

## Requirements

- **Fedora 43** (enforced by role)
- Root/sudo access (uses `become: true`)
- DNF package manager

## Role Variables

### Feature Toggles

| Variable                         | Default | Description                               |
| -------------------------------- | ------- | ----------------------------------------- |
| `kernel_install_lts`             | `true`  | Install kernel-longterm packages          |
| `kernel_exclude_standard`        | `true`  | Configure DNF to exclude standard kernels |
| `kernel_apply_versionlock`       | `true`  | Apply version lock to LTS kernel          |
| `kernel_remove_standard_kernels` | `true`  | Remove standard kernel packages           |
| `kernel_auto_reboot`             | `false` | Automatically reboot after kernel change  |

### System Configuration

| Variable                  | Default             | Description                 |
| ------------------------- | ------------------- | --------------------------- |
| `kernel_required_distro`  | `Fedora`            | Required distribution       |
| `kernel_required_version` | `43`                | Required Fedora version     |
| `kernel_reboot_timeout`   | `600`               | Reboot timeout in seconds   |
| `kernel_reboot_message`   | Descriptive message | Message shown during reboot |

### Package & Repository Configuration

| Variable                       | Default                        | Description                    |
| ------------------------------ | ------------------------------ | ------------------------------ |
| `kernel_lts_copr_repo`         | `kwizart/kernel-longterm-6.12` | COPR repository for LTS kernel |
| `kernel_lts_packages`          | List of LTS packages           | Kernel packages to install     |
| `kernel_dnf_plugins`           | DNF core & versionlock         | Required DNF plugins           |
| `kernel_standard_exclude_list` | Standard kernel packages       | Packages to exclude from DNF   |

## Examples

### Basic Usage (No Reboot)

```yaml
- hosts: all
  become: true
  roles:
    - kernel
```

### With Automatic Reboot

```yaml
- hosts: all
  become: true
  vars:
    kernel_auto_reboot: true
  roles:
    - kernel
```

### Custom Configuration

```yaml
- hosts: fedora43_servers
  become: true
  vars:
    kernel_install_lts: true
    kernel_exclude_standard: true
    kernel_apply_versionlock: true
    kernel_remove_standard_kernels: true
    kernel_auto_reboot: true
    kernel_reboot_timeout: 900
  roles:
    - kernel
```

### Skip Standard Kernel Removal (Conservative Approach)

```yaml
- hosts: all
  become: true
  vars:
    kernel_remove_standard_kernels: false
  roles:
    - kernel
```

## Role Execution Steps

1. **Verify System**: Assert Fedora 43
2. **Configure DNF**: Add kernel exclusions to `/etc/dnf/dnf.conf`
3. **Install Plugins**: Install dnf5-plugins-core and python3-dnf-plugin-versionlock
4. **Enable COPR**: Add kwizart/kernel-longterm-6.12 repository
5. **Install LTS**: Install kernel-longterm packages (bypassing temporary DNF excludes)
6. **Get Version**: Query installed LTS kernel version
7. **Apply Lock**: Lock LTS kernel version with versionlock
8. **Remove Standard**: Remove standard (non-LTS) kernel packages
9. **Reboot** (optional): Trigger system reboot

## Important Notes

⚠️ **Always Test First**: Test this role in a development environment before production use.

🔧 **DNF Exclude Handling**: The role temporarily disables DNF excludes (`disable_excludes: main`) during LTS installation to ensure kernel packages are found and installed, even though we've excluded them in the main DNF config.

🔒 **Smart Removal**: Standard kernel removal is careful and checks package names to ensure only non-LTS kernels are removed.

🔄 **Manual Reboot**: If `kernel_auto_reboot` is `false` (default), you must manually reboot to use the new kernel.

## Tags

Use tags to run specific parts of the role:

```bash
# Run only verification
ansible-playbook playbook.yml -t kernel-verify

# Run only installation
ansible-playbook playbook.yml -t kernel-install,kernel-lock

# Run cleanup only
ansible-playbook playbook.yml -t kernel-cleanup
```

Available tags:

- `kernel` - All kernel tasks
- `kernel-verify` - Verify system requirements
- `kernel-config` - Configure DNF
- `kernel-plugins` - Install DNF plugins
- `kernel-copr` - Enable COPR repository
- `kernel-install` - Install LTS kernel
- `kernel-version` - Get kernel version
- `kernel-lock` - Apply version lock
- `kernel-cleanup` - Remove standard kernels
- `kernel-reboot` - Trigger reboot

## Troubleshooting

### Kernel Installation Fails

1. Verify Fedora 43: `cat /etc/os-release`
2. Check COPR availability: `dnf copr status kwizart/kernel-longterm-6.12`
3. Check DNF cache: `dnf clean all && dnf makecache`

### Versionlock Plugin Missing

```bash
dnf install python3-dnf-plugin-versionlock
```

### Cannot Remove Standard Kernels

- Check what's installed: `rpm -qa | grep ^kernel`
- Verify LTS is installed: `rpm -q kernel-longterm`
- Check boot entry: `grubby --info=ALL`

### Manual Recovery

If needed, remove versionlock temporarily:

```bash
dnf versionlock delete "*"
```

## Dependencies

This role has no dependencies on other roles.

## License

SPDX-License-Identifier: MIT-0
