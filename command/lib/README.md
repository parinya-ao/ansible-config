# Ansible Config - DDD Architecture

This directory contains the library modules for `init.sh`, organized using **Domain-Driven Design (DDD)** principles.

## Architecture Overview

```
command/lib/
├── Shared Kernel (Common utilities & messaging)
│   ├── colors.sh                    # Color definitions
│   ├── print_*.sh                   # UI output functions
│   └── utils/
│       ├── command_utils.sh         # Command execution utilities
│       ├── usage.sh                 # Usage information
│       ├── parsing.sh               # Argument parsing
│       ├── cleanup.sh               # Cleanup handlers
│       ├── checks.sh                # Pre-flight checks
│       ├── version_display.sh       # Version display
│       └── messages.sh              # Success/failure messages
│
├── Domain Layer (Business logic)
│   └── domain/
│       ├── system_checks.sh         # OS & system validation
│       └── dnf_checks.sh            # DNF lock detection
│
├── Infrastructure Layer (External services)
│   └── infrastructure/
│       └── dnf_installer.sh         # DNF package installation
│
└── Application Layer (Use cases & workflows)
    └── application/
        ├── package_installer.sh     # System package installation
        ├── venv_setup.sh            # Python virtual environment
        ├── collections_installer.sh # Ansible collections
        └── playbook_runner.sh       # Ansible playbook execution
```

## Layer Responsibilities

### Shared Kernel
- Common utilities shared across all bounded contexts
- UI/output functions for consistent user experience
- No dependencies on other layers

### Domain Layer
- **Core business logic** for system validation
- Contains `verify_fedora()`, `check_disk_space()`, `check_dnf_lock()`
- Independent of infrastructure concerns
- Uses ubiquitous language: "verify", "check", "validate"

### Application Layer
- **Orchestrates workflows** and use cases
- Coordinates between domain and infrastructure
- Contains high-level operations: `install_packages()`, `setup_venv()`
- Manages the installation lifecycle

### Infrastructure Layer
- **External service integration**
- Handles DNF package manager interactions
- Implements retry logic and error handling
- Isolates external dependencies from domain logic

## Design Principles

1. **Ubiquitous Language**: Function names reflect business terminology
2. **Separation of Concerns**: Each layer has distinct responsibilities
3. **Dependency Inversion**: Application depends on Domain, not Infrastructure
4. **Single Responsibility**: Each library has one clear purpose

## Usage Example

```bash
# init.sh loads libraries in DDD layer order:
# 1. Shared Kernel (utils, colors, print functions)
# 2. Domain Layer (business logic)
# 3. Infrastructure Layer (external services)
# 4. Application Layer (workflows)

./init.sh --skip-install
```

## Extending the Architecture

To add new functionality:

1. **Domain Layer**: Add business logic to `domain/`
2. **Infrastructure Layer**: Add external service adapters to `infrastructure/`
3. **Application Layer**: Create new use case in `application/`
4. **Shared Kernel**: Add reusable utilities to `utils/`

## References

- [Domain-Driven Design](https://www.domainlanguage.com/ddd/) by Eric Evans
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) by Robert C. Martin
