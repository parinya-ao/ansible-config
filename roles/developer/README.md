# Developer Role

This role installs and configures a complete development environment on Fedora systems, including compilers, language runtimes, and essential CLI tools for software development.

## Role Purpose

The developer role automates the setup of a fully-functional development environment including:
- System compilers and build tools (GCC, Clang, CMake, Make)
- Development editors (Neovim, Tmux)
- Language runtimes (Golang, Java 21 OpenJDK)
- Rust toolchain via rustup
- Bun JavaScript runtime
- uv (modern Python package manager)

## Requirements

- Fedora-based system
- Ansible 2.15+
- Internet connection for downloading language runtimes

## Role Variables

### Feature Toggles

Control which components are installed by setting these variables to `true` or `false`:

```yaml
developer_install_rust: true        # Install Rust toolchain via rustup
developer_install_bun: true         # Install Bun runtime
developer_install_uv: true          # Install uv (Python package manager)
```

### Compiler Packages

Default list of system packages to install:

```yaml
developer_compilers_packages:
  - clang          # C/C++ compiler
  - gcc            # GNU Compiler Collection
  - gcc-c++        # C++ compiler
  - cmake          # Build system generator
  - gdb            # GNU Debugger
  - neovim         # Vim-fork text editor
  - tmux           # Terminal multiplexer
  - golang         # Go programming language
  - python3-devel  # Python development headers
  - toolbox        # Fedora container toolbox
  - java-21-openjdk-devel  # Java 21 JDK
  - java-21-openjdk         # Java 21 runtime
  - cloc           # Count Lines of Code
  - make           # Build automation tool
  - automake       # Make file generator
  - autoconf       # Configuration script generator
```

### Rust Configuration

```yaml
developer_rustup_default_host: "x86_64-unknown-linux-gnu"
```

### Python Tooling

```yaml
developer_use_uv_latest: true       # Always install latest uv version
```

## Dependencies

None. This role is self-contained and can be used independently.

## Example Playbook

### Basic Usage

```yaml
---
- hosts: developer_workstations
  roles:
    - developer
```

### Custom Configuration

```yaml
---
- hosts: developer_workstations
  roles:
    - role: developer
      vars:
        # Skip Rust installation
        developer_install_rust: false

        # Add additional packages
        developer_compilers_packages:
          - gcc
          - clang
          - cmake
          - neovim
          - llvm
          - lldb
```

### Selective Installation with Tags

```bash
# Install only compilers and system tools
ansible-playbook playbook.yml --tags "compilers"

# Install only Rust
ansible-playbook playbook.yml --tags "rust"
```

## Installed Tools Overview

| Category | Tool | Version Management |
|----------|------|-------------------|
| Compilers | GCC, Clang | System (dnf) |
| Build Tools | CMake, Make, Automake | System (dnf) |
| Editors | Neovim | System (dnf) |
| Go | Golang | System (dnf) |
| Java | OpenJDK 21 | System (dnf) |
| Rust | rustup + cargo | rustup |
| Bun | Bun | Installer (per-user) |
| Python | uv | Installer (per-user) |

## Directory Structure

```
roles/developer/
├── defaults/
│   └── main.yml          # Default variables
├── handlers/
│   └── main.yml          # Handlers (none currently)
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   ├── main.yml          # Main entry point
│   ├── compilers.yml     # System compilers and tools
│   ├── rust.yml          # Rust toolchain
│   ├── bun.yml           # Bun runtime
│   └── python.yml        # uv Python tooling
├── tests/
│   ├── inventory
│   └── test.yml
├── vars/
│   └── main.yml          # Role variables (empty, using defaults)
└── README.md             # This file
```

## License

MIT-0

## Author

Ansible Developer Configuration