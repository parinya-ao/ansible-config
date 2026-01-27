# Ansible Role: font

Install recommended fonts for Fedora Linux systems.

## Description

This role installs essential font packages for Fedora, organized by category:

### Thai Language Fonts
- **tlwg-fonts**: Standard Thai fonts (Loma, Norasi, Garuda, Kinnari)
- **google-noto-sans-thai**: Noto Thai Sans - high quality replacement for Cordia
- **google-noto-serif-thai**: Noto Thai Serif - high quality replacement for Angsana
- **sarabun-fonts**: TH Sarabun - official Thai government font for documents

### Unicode and Multilingual Fonts
- **google-noto-fonts-all**: Comprehensive coverage for most languages
- **google-noto-cjk-fonts**: Chinese, Japanese, and Korean fonts

### Code and Terminal Fonts
- **fira-code-fonts**: Popular coding font with ligatures
- **jetbrains-mono-fonts**: Another popular developer font
- **powerline-fonts**: Required for shell themes with special symbols

### Emoji and Symbol Fonts
- **google-noto-emoji-fonts**: Prevents emoji display issues

### Microsoft Fonts (Optional)
- **msttcore-fonts**: Times New Roman, Arial, Courier New for old Word files
  - Requires rpmfusion repository
  - Disabled by default

## Requirements

- Fedora Linux
- `dnf` package manager
- `sudo` or root access

## Role Variables

### Installation Control

Enable or disable font installation by category:

```yaml
# Enable Thai fonts (default: true)
font_install_thai: true

# Enable Unicode fonts (default: true)
font_install_unicode: true

# Enable code fonts (default: true)
font_install_code: true

# Enable emoji fonts (default: true)
font_install_emoji: true

# Enable Microsoft fonts (default: false)
# Requires rpmfusion repository
font_install_microsoft: false
```

### Font Cache Command

Customize the font cache refresh command:

```yaml
font_cache_command: fc-cache -fv
```

### Font Package Lists

You can customize the font packages installed in each category:

```yaml
# Thai language fonts
font_packages_thai:
  - tlwg-fonts
  - google-noto-sans-thai
  - google-noto-serif-thai
  - sarabun-fonts

# Unicode and multilingual fonts
font_packages_unicode:
  - google-noto-fonts-all
  - google-noto-cjk-fonts

# Code and terminal fonts
font_packages_code:
  - fira-code-fonts
  - jetbrains-mono-fonts
  - powerline-fonts

# Emoji fonts
font_packages_emoji:
  - google-noto-emoji-fonts

# Microsoft fonts
font_packages_microsoft:
  - msttcore-fonts
```

## Usage

### Basic Usage

Install all default font packages:

```yaml
- hosts: all
  become: true
  roles:
    - font
```

### Selective Installation

Install only specific font categories:

```yaml
- hosts: all
  become: true
  roles:
    - role: font
      font_install_thai: true
      font_install_code: true
      font_install_unicode: false
      font_install_emoji: false
      font_install_microsoft: false
```

### Enable Microsoft Fonts

To install Microsoft fonts, enable rpmfusion repository first:

```yaml
- hosts: all
  become: true
  roles:
    - role: font
      font_install_microsoft: true
```

### Custom Font Packages

Install custom font packages:

```yaml
- hosts: all
  become: true
  roles:
    - role: font
      font_packages_thai:
        - tlwg-fonts
        - google-noto-sans-thai
```

## Dependencies

None.

## License

MIT-0

## Author Information

This role is part of the ansible-config project.

## Best Practices

1. **Thai Users**: Keep `font_install_thai: true` for proper Thai language support
2. **Developers**: Keep `font_install_code: true` for coding and terminal usage
3. **Multilingual**: Keep `font_install_unicode: true` for international character support
4. **Microsoft Fonts**: Only enable if you need compatibility with old Office documents
5. **Font Cache**: The role automatically refreshes the font cache after installation

## Notes

- The role uses `dnf` to install packages, which is Fedora's default package manager
- Font cache is automatically refreshed after installation
- Microsoft fonts installation will not fail if rpmfusion is not enabled (uses `ignore_errors: true`)
- All fonts are installed system-wide in `/usr/share/fonts`