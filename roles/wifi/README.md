# Wi-Fi Configuration Role

An Ansible role for configuring and optimizing Wi-Fi on Fedora/RHEL systems to ensure maximum stability and connectivity.

## Description

This role provides three distinct Wi-Fi configuration modes:

1. **unblock** - Ensure Wi-Fi is never blocked and stays enabled
2. **disable_powersave** - Disable Wi-Fi power save for Intel Wi-Fi cards
3. **no_powersave** - Disable ALL Wi-Fi power saving for maximum stability (default)

## Requirements

- Ansible 2.9+
- Fedora / RHEL / Rocky / Alma Linux
- NetworkManager
- Systemd

## Role Variables

### `wifi_task` (required)

Specifies which Wi-Fi configuration task to run.

- **Default:** `"no_powersave"`
- **Options:**
  - `unblock` - Unblock Wi-Fi and ensure it stays enabled
  - `disable_powersave` - Disable Wi-Fi power save (Intel only)
  - `no_powersave` - Disable ALL Wi-Fi power saving for maximum stability

## Dependencies

None.

## Example Playbook

### Unblock Wi-Fi

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "unblock"
```

### Disable Power Save (Intel Only)

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "disable_powersave"
```

### Maximum Stability (No Power Save)

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
```

### Run on Localhost

```yaml
---
- hosts: localhost
  connection: local
  become: true
  roles:
    - role: wifi
```

## Task Details

### `unblock` Task

This task:
- Checks rfkill status and unblocks any soft-blocked Wi-Fi devices
- Forces NetworkManager to enable Wi-Fi radio
- Ensures NetworkManager is running and enabled
- Disables acer_wmi module (Acer only) to prevent soft blocks
- Creates persistent NetworkManager configuration

### `disable_powersave` Task

This task (Intel Wi-Fi only):
- Detects iwlwifi module
- Disables NetworkManager Wi-Fi power save
- Disables iwlwifi firmware power saving
- Sets kernel parameter `iwlwifi.power_save=0`

### `no_powersave` Task

This task (maximum stability):
- Auto-detects all Wi-Fi interfaces
- Disables NetworkManager Wi-Fi power save
- Disables MAC randomization for DHCP stability
- Disables iwlwifi firmware power management (power_level=0, power_save=0, disable_11ax=1)
- Sets kernel parameter `iwlwifi.power_save=0`
- Forces power_save off on all Wi-Fi interfaces at runtime

**Note:** Requires reboot for kernel parameters and module options to take full effect.

## Bulletproof WiFi Policy (Standalone Playbook)

For Fedora systems requiring maximum Wi-Fi stability across all networks, use the `fix_all_wifi.yml` playbook. This playbook applies comprehensive global policies to prevent Wi-Fi drops, especially on Intel CNVi chipsets with new kernels.

### What It Does

1. **Force Enable Wi-Fi** - Recovers Wi-Fi radio if it's been software disabled
2. **Global Configuration** - Applies settings to all new Wi-Fi connections
3. **Remediation** - Updates all existing Wi-Fi profiles (home, office, coffee shops, etc.)

### Features

- **Disable MAC Randomization** - Prevents DHCP failures and connection drops
- **Disable Power Saving** - Fixes Intel CNVi sleep/wake issues on new kernels
- **Prevent RFKill Drops** - Stops Wi-Fi from being blocked by system events
- **Increase DHCP Timeout** - Allows more time for slow DHCP servers
- **Set `may-fail` to no** - Ensures IPv4 must be obtained before connection is complete

### Usage

```bash
# Run the playbook on localhost
ansible-playbook roles/wifi/fix_all_wifi.yml --ask-become-pass

# Or run with sudo directly
sudo ansible-playbook roles/wifi/fix_all_wifi.yml
```

### What to Expect After Running

After 10-15 seconds (NetworkManager restart time):
- Wi-Fi radio will be enabled
- All existing Wi-Fi profiles will have stability settings applied
- All new Wi-Fi connections will use stability settings automatically
- `nmcli` should show `connected` instead of `unavailable ... sw disabled`

### Verification

```bash
# Check Wi-Fi radio is enabled
nmcli radio wifi

# Check connected status
nmcli -t -f NAME,TYPE,DEVICE connection show --active

# Verify Wi-Fi interface has no power save
iw dev wlp0s20f3 get power_save  # Replace wlp0s20f3 with your interface
```

**Note:** This playbook is ideal for Fedora systems experiencing:
- Wi-Fi dropping after sleep/resume
- Intermittent disconnections
- Slow or failed DHCP negotiation
- Software disabled Wi-Fi after updates

## Verification

After running the role, verify with:

```bash
# Check Wi-Fi status
rfkill list

# Check NetworkManager radio status
nmcli radio

# Check power save status (no_powersave mode)
iw dev <interface> get power_save

# Check NetworkManager logs
journalctl -fu NetworkManager
```

Expected results:
- `Soft blocked: no`
- `Hard blocked: no`
- `WIFI: enabled`
- `Power save: off` (no_powersave mode)

## License

MIT

## Author Information

- parinya-ao