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

### Intel iwlwifi Driver Options (for `no_powersave` mode)

These options control Intel Wi-Fi driver power management and coexistence features:

#### `wifi_iwlwifi_uapsd_disable`

Disable U-APSD (Unscheduled Automatic Power Save Delivery).

- **Default:** `true`
- **Effect:** Prevents "Connected, No Internet" issues and connection drops with older routers
- **Trade-off:** None (no practical downside)

#### `wifi_iwlwifi_d0i3_disable`

Disable D0i3 (Intel Wi-Fi deep sleep state).

- **Default:** `true`
- **Effect:** Prevents network "stalls" where connection stays active but no data flows
- **Trade-off:** None (recommended for AC-connected laptops)

#### `wifi_iwlwifi_11n_disable`

Disable 802.11n (HT mode) for maximum stability in crowded areas.

- **Default:** `false`
- **Effect:** Significantly improves connection stability in areas with many nearby Wi-Fi networks
- **Trade-off:** Reduces maximum speed (802.11ac/ax still available)
- **Recommended for:** Condos, offices, crowded areas

#### `wifi_iwlwifi_11n_disable_value`

11n_disable value when enabled.

- **Default:** `"8"` (disable aggressive TX aggregation only)
- **Options:** `"1"` = disable all HT, `"8"` = disable TX aggregation only

### Bluetooth Coexistence Options

#### `wifi_iwlwifi_bt_coex_active`

Enable Bluetooth/Wi-Fi coexistence at driver level.

- **Default:** `true`
- **Effect:** When `true`, allows Bluetooth and Wi-Fi to share 2.4GHz band intelligently
- **Usage:** Set to `true` if using Bluetooth mouse/keyboard/headphones with Wi-Fi
- **Note:** For best results, force Wi-Fi to 5GHz when using Bluetooth devices

#### `wifi_iwlwifi_scan_ant_prio_enable`

Reduce scanning frequency to prevent Bluetooth audio stuttering.

- **Default:** `true`
- **Effect:** Prevents Bluetooth audio glitches during Wi-Fi scanning
- **Trade-off:** May slightly slow down network discovery

### CPU Optimization Options

#### `wifi_iwlwifi_swcrypto`

Use hardware (0) or software (1) encryption.

- **Default:** `"0"` (hardware)
- **Hardware (0):** Lower CPU usage, Wi-Fi chip handles encryption
- **Software (1):** Higher CPU usage, more stable if firmware has bugs
- **Recommendation:** Use `0` for AC-connected laptops, `1` only if experiencing encryption-related issues

### Network Stack Optimization

#### `wifi_enable_network_tuning`

Enable kernel network stack tuning for reduced CPU overhead.

- **Default:** `true`
- **Effects:**
  - Increases buffer sizes to reduce interrupt frequency
  - Installs and enables `irqbalance` for interrupt distribution
- **Trade-off:** Uses slightly more RAM (negligible on modern systems)

### Bluetooth Latency Optimization

#### `wifi_enable_bluetooth_optimization`

Enable Bluetooth-specific kernel tuning for multiple BT devices.

- **Default:** `true`
- **Effects:**
  - Increases `net.core.netdev_max_backlog` to 5000
  - Reduces Bluetooth input queue delay
  - Helps prevent mouse/keyboard/audio stuttering when used with Wi-Fi
- **Recommended for:** Systems using Bluetooth mouse, keyboard, and/or headphones simultaneously
- **Trade-off:** Slightly increases network buffer memory usage

### USB Tethering Optimization

#### `wifi_disable_usb_autosuspend`

Disable USB autosuspend for stable USB tethering.

- **Default:** `true`
- **Effect:** Prevents USB internet disconnects and Error -71 in dmesg
- **Recommendation:** Enable when using USB tethering as failover

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

### Maximum Stability in Crowded Areas (Disable 11n)

For condos, offices, or areas with many nearby Wi-Fi networks:

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
        wifi_iwlwifi_11n_disable: true
```

### Wi-Fi with Bluetooth Devices (Mouse, Keyboard, Headphones)

Optimized for using Bluetooth peripherals with Wi-Fi:

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
        # Enable Bluetooth coexistence
        wifi_iwlwifi_bt_coex_active: true
        wifi_iwlwifi_scan_ant_prio_enable: true
```

**Important:** For best results, force Wi-Fi to use 5GHz band in NetworkManager to avoid 2.4GHz interference with Bluetooth.

### Wi-Fi Only (No Bluetooth - Maximum Performance)

Disable Bluetooth coexistence for pure Wi-Fi performance:

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
        wifi_iwlwifi_bt_coex_active: false
```

### USB Tethering Failover Setup

Optimized for systems using USB tethering as backup:

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
        # Disable USB autosuspend for stable tethering
        wifi_disable_usb_autosuspend: true
        # Enable network tuning
        wifi_enable_network_tuning: true
```

### CPU-Optimized Configuration (AC Connected)

For laptops always plugged in, minimizing CPU usage:

```yaml
---
- hosts: all
  become: true
  roles:
    - role: wifi
      vars:
        wifi_task: "no_powersave"
        # Use hardware encryption (lowest CPU)
        wifi_iwlwifi_swcrypto: "0"
        # Enable network stack tuning
        wifi_enable_network_tuning: true
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
- Disables iwlwifi firmware power management (power_level=0, power_save=0, uapsd_disable=1, d0i3_disable=1, disable_11ax=1)
- Optionally disables 802.11n for crowded areas (controlled by `wifi_iwlwifi_11n_disable`)
- Configures Bluetooth coexistence (bt_coex_active=1 by default)
- Uses hardware encryption for reduced CPU usage (swcrypto=0)
- Configures network stack buffers for reduced interrupt frequency
- Configures Bluetooth latency optimization (netdev_max_backlog=5000)
- Disables USB autosuspend for stable USB tethering
- Installs and enables irqbalance for interrupt distribution across CPU cores
- Sets kernel parameter `iwlwifi.power_save=0`
- Forces power_save off on all Wi-Fi interfaces at runtime
- **Skips automatically in CI environments** (detected via `CI` environment variable)

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