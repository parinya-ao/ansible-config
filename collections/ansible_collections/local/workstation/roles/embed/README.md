# Embed Role

Embedded development environment setup for Fedora Workstation.

## Features

- **ARM GCC Toolchain**: `arm-none-eabi-gcc-cs`, `arm-none-eabi-binutils-cs`, `arm-none-eabi-newlib`
- **STM32CubeMX**: Installed via Flatpak from Flathub
- **ESP Tools**: esptool for ESP32/ESP8266 development
- **Serial Debugging**: minicom for serial port debugging
- **Dialout Group**: Adds user to dialout group for serial device access

## Usage

```bash
# Run complete embed role
ansible-playbook playbook.yaml --tags embed

# Run only ARM toolchain setup
ansible-playbook playbook.yaml --tags arm

# Run only STM32CubeMX installation
ansible-playbook playbook.yaml --tags stm32
```

## Variables

See `defaults/main.yml` for all configurable variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `embed_install_arm_toolchain` | `true` | Install ARM GCC toolchain |
| `embed_install_stm32cubemx` | `true` | Install STM32CubeMX via Flatpak |
| `embed_install_esp_tools` | `true` | Install ESP development tools |
| `embed_install_serial_tools` | `true` | Install serial debugging tools |
| `embed_configure_dialout_group` | `true` | Add user to dialout group |
| `embed_workspace_dir` | `~/develop/embed` | Workspace directory |

## After Installation

### Log out and log back in
The dialout group change requires a new login session:
```bash
# Log out and log back in, then verify:
groups
```

### Verify ARM toolchain
```bash
arm-none-eabi-gcc --version
```

### Launch STM32CubeMX
```bash
flatpak run com.st.STM32CubeMX
```

### Serial Debugging with minicom
```bash
# Find the serial port
ls /dev/ttyACM*

# Connect with minicom (115200 baud for most STM32/ESP boards)
minicom -D /dev/ttyACM0 -b 115200

# Exit: Ctrl+A, then Q
```

### Flash with esptool
```bash
# Example: Flash ESP32
esptool --chip esp32 --port /dev/ttyUSB0 write_flash 0x1000 firmware.bin
```
