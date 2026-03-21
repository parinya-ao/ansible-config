# DNF Upgrade Timeout Removed

## Summary

Removed timeout restrictions on `dnf upgrade -y` commands in the Ansible configuration to allow system updates to complete without interruption.

## Changes Made

### 1. Removed Global DNF Timeout Variable

**File:** `inventory/group_vars/all.yml`

```yaml
# Before:
dnf_max_retries: 3
dnf_retry_delay: 5
dnf_timeout_seconds: 300  # ❌ Removed

# After:
dnf_max_retries: 3
dnf_retry_delay: 5
# No timeout on DNF operations - allows long-running updates to complete
```

### 2. Added Documentation in system_update.yml

**File:** `collections/ansible_collections/local/workstation/roles/common/tasks/system_update.yml`

```yaml
---
# SPDX-License-Identifier: MIT-0
# System update tasks with auto-recovery
# Note: No timeout is set on dnf upgrade commands to allow long-running updates to complete

- name: Managed System Update Operation
  block:
    - name: Update all packages (refresh metadata + upgrade)
      ansible.builtin.command: dnf upgrade --refresh -y -v
      become: true
      # ...
      # No timeout - allows unlimited time for system updates
```

### 3. Updated Common Role Defaults

**File:** `collections/ansible_collections/local/workstation/roles/common/defaults/main.yml`

```yaml
# DNF retry settings (for network resilience)
# No timeout is set - allows long-running updates to complete
common_dnf_retries: 3
common_dnf_delay: 10
```

## Why This Matters

### Problem
- Fedora system updates can take a long time (especially major version upgrades)
- A 300-second (5-minute) timeout could interrupt important updates
- Interrupted updates can leave the system in an inconsistent state
- Large updates (kernel, desktop environment, development tools) often exceed 5 minutes

### Solution
- **No timeout**: DNF upgrade commands now run until completion
- **Retry logic**: Still has 3 retries with 10-second delay for transient failures
- **Recovery**: Auto-recovery tasks handle locked databases or failed updates

## Affected Commands

The following commands now run **without timeout**:

```bash
# Main system update command
dnf upgrade --refresh -y -v

# Retry command (after recovery)
dnf upgrade --refresh -y
```

## Verification

Run the system update and verify no timeout occurs:

```bash
cd /home/parinya/ansible-config

# Run common role (includes system update)
ansible-playbook playbook.yaml --tags common

# Or run the entire playbook
ansible-playbook playbook.yaml
```

### Monitor Update Progress

The update process will:
1. Download metadata from all repositories
2. Calculate available updates
3. Download all packages (with parallel downloads)
4. Install updates
5. Run post-transaction scripts
6. Run health checks

**Expected behavior:**
- ✅ Updates run until completion (no matter how long)
- ✅ Verbose output shows progress
- ✅ Automatic retry on transient failures (3 attempts)
- ✅ Recovery tasks run if update fails

## What Still Has Timeout Protection

Some tasks still have timeouts for safety:

| Task | Timeout | Reason |
|------|---------|--------|
| Desktop notifications | 10s | Prevent hanging notifications |
| Preflight checks | 30s | Fast failure for missing dependencies |
| Recovery tasks | 10s | Prevent stuck recovery |
| Molecule tests | 30-300s | CI/CD pipeline timeouts |

## DNF Configuration

Current DNF settings for optimal performance:

```yaml
common_dnf_max_parallel_downloads: 20  # Faster downloads
common_dnf_fastestmirror: "True"        # Use fastest mirror
common_dnf_metadata_expire: "6h"        # Cache metadata for 6 hours
common_dnf_deltarpm: "False"            # Don't use deltarpms (more reliable)
common_dnf_retries: 3                   # Retry on failure
common_dnf_delay: 10                    # 10 seconds between retries
# NO TIMEOUT            ✅
```

## Troubleshooting

### If Updates Still Seem to Timeout

1. **Check if it's Ansible or DNF:**
   ```bash
   # Run DNF manually
   sudo dnf upgrade --refresh -y -v
   
   # If this completes but Ansible fails, check:
   # - SSH timeout settings
   # - Ansible connection timeout
   # - CI/CD pipeline timeout
   ```

2. **Check for DNF locks:**
   ```bash
   # Remove stale DNF locks
   sudo rm -f /var/run/dnf.pid
   sudo rm -f /var/lib/dnf/locks/*
   ```

3. **Run with increased verbosity:**
   ```bash
   ansible-playbook playbook.yaml -vvv --tags common
   ```

### If Updates Take Too Long

Consider running updates separately:

```bash
# Update system first (outside Ansible)
sudo dnf upgrade --refresh -y

# Then run Ansible for configuration
ansible-playbook playbook.yaml --skip-tags common
```

## References

- [DNF Documentation](https://dnf.readthedocs.io/)
- [Fedora System Updates](https://docs.fedoraproject.org/en-US/quick-docs/dnf-upgrade/)
- [Ansible Command Module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)

## Related Changes

This change complements other improvements:
- ✅ RPM Fusion repository setup
- ✅ Non-free firmware installation
- ✅ Intel media drivers
- ✅ Flatpak application management
- ✅ SSH permissions configuration

---

**Last Updated:** March 21, 2026  
**Affected Roles:** `common` (system_update tasks)
