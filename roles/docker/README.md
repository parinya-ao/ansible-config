# Docker Role

This role installs and configures Docker CE (Community Edition) on Fedora/RHEL systems, including containerd, BuildKit plugin, and Docker Compose plugin.

## Role Purpose

The docker role automates the complete Docker CE installation:
- Removal of old/obsolete Docker packages
- Docker CE repository configuration from official source
- Installation of Docker CE, CLI, containerd, BuildKit, and Compose plugin
- Docker service management (start and enable)
- User group configuration for non-root Docker access

## Requirements

- RHEL/Fedora-based system (Fedora 39+, RHEL 9+)
- Ansible 2.15+
- Root or sudo access
- Internet connection for Docker repository

## Role Variables

### Feature Toggles

```yaml
# Remove old Docker packages before installation
docker_remove_old_packages: true

# Add current user to docker group
docker_add_user_to_group: true

# Enable Docker CE repository
docker_enable_repo: true
```

### Repository Configuration

```yaml
# Docker CE repository URL
docker_repo_url: "https://download.docker.com/linux/centos/docker-ce.repo"
```

### Package Lists

Old packages to remove (from official Docker documentation):

```yaml
docker_old_packages:
  - docker
  - docker-client
  - docker-client-latest
  - docker-common
  - docker-latest
  - docker-latest-logrotate
  - docker-logrotate
  - docker-engine
```

Docker CE packages to install:

```yaml
docker_packages:
  - docker-ce              # Docker CE engine
  - docker-ce-cli          # Docker CLI
  - containerd.io          # Container runtime
  - docker-buildx-plugin   # BuildKit plugin
  - docker-compose-plugin  # Docker Compose V2
```

### User Configuration

```yaml
# User to add to docker group (default: current user)
docker_user: "{{ ansible_user_id }}"
```

### Retry Settings

```yaml
# Installation retry settings for network resilience
docker_install_retries: 3
docker_install_delay: 10
```

### Daemon Configuration

```yaml
# Optional Docker daemon configuration
docker_daemon_config: {}
  # Example: Enable BuildKit
  # features:
  #   buildkit: true
```

## Dependencies

None. This role is self-contained. Optionally, you can add the `common` role as a dependency for base system configuration.

## Example Playbook

### Basic Usage

```yaml
---
- hosts: docker_hosts
  roles:
    - docker
```

### Custom Configuration

```yaml
---
- hosts: docker_hosts
  roles:
    - role: docker
      vars:
        # Skip removing old packages (if already clean)
        docker_remove_old_packages: false

        # Use different Docker repository mirror
        docker_repo_url: "https://mirror.example.com/docker-ce.repo"

        # Add specific user to docker group
        docker_user: "devops"
```

### With Common Role Dependency

```yaml
---
# roles/docker/meta/main.yml
dependencies:
  - role: common
```

### Selective Installation with Tags

```bash
# Remove old packages only
ansible-playbook playbook.yml --tags "cleanup"

# Configure repository only
ansible-playbook playbook.yml --tags "repository"

# Install Docker packages only
ansible-playbook playbook.yml --tags "packages"

# Configure Docker service only
ansible-playbook playbook.yml --tags "service"

# Configure user access only
ansible-playbook playbook.yml --tags "users"
```

## Directory Structure

```
roles/docker/
├── defaults/
│   └── main.yml          # Default variables
├── handlers/
│   └── main.yml          # Handlers (restart, reload, notifications)
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   ├── main.yml          # Main entry point
│   ├── remove-old.yml    # Remove obsolete Docker packages
│   ├── repository.yml    # Configure Docker CE repository
│   ├── packages.yml      # Install Docker CE packages
│   ├── service.yml       # Manage Docker service
│   └── user-group.yml    # Configure user/group access
├── tests/
│   ├── inventory
│   └── test.yml
├── vars/
│   └── main.yml          # Role variables (empty, using defaults)
└── README.md             # This file
```

## Installed Components

| Component | Description | Version |
|-----------|-------------|---------|
| docker-ce | Docker CE Engine | Latest from repo |
| docker-ce-cli | Docker Command Line Interface | Latest from repo |
| containerd.io | Container runtime | Latest from repo |
| docker-buildx-plugin | BuildKit plugin | Latest from repo |
| docker-compose-plugin | Docker Compose V2 | Latest from repo |

## Post-Installation

After running this role, you can verify Docker installation:

```bash
# Check Docker version
docker --version

# Check Docker system info
docker info

# Run a test container
docker run --rm hello-world
```

### Group Access Notice

When a user is added to the `docker` group, you must either:
- Log out and log back in, OR
- Run: `newgrp docker`

for the group changes to take effect.

## Security Considerations

Adding users to the `docker` group grants them equivalent to root access. Only add trusted users to this group. See [Docker Security](https://docs.docker.com/engine/security/) for more information.

## License

MIT-0

## Author

Ansible Docker Configuration
