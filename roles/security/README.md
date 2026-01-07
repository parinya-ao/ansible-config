# Security Role

This role configures system security settings, primarily firewall management using firewalld on RHEL/Fedora systems.

## Role Purpose

The security role automates the configuration of:
- Firewalld service installation and startup
- SSH port opening (default port 22)
- Custom port opening with flexible protocol support
- Permanent and immediate firewall rule application

## Requirements

- RHEL/Fedora-based system with firewalld support
- `ansible.posix` collection (for firewalld module)
- `common` role as dependency

## Role Variables

### Default Variables (`defaults/main.yml`)

- `security_enable_firewalld` (bool): Enable firewalld service (default: `true`)
- `security_ssh_port` (int): SSH port to open (default: `22`)
- `security_custom_ports` (list): List of custom ports to open (default: `[]`)

### Custom Ports Format

```yaml
security_custom_ports:
  - port: 8080
    protocol: tcp
    state: enabled

  - port: 53
    protocol: udp
    state: enabled

  - port: 3000
    protocol: tcp
    state: disabled
```

## Included Tasks

- **firewalld.yml**: Install and configure firewalld service
- **ssh.yml**: Open SSH port using firewalld
- **custom-ports.yml**: Open custom ports (when `security_custom_ports` is defined)

## Dependencies

- **common**: Base system configuration role

## Example Playbook

### Basic Usage (SSH only)

```yaml
---
- hosts: localhost
  roles:
    - security
```

### With Custom Ports

```yaml
---
- hosts: localhost
  roles:
    - role: security
      vars:
        security_ssh_port: 2222
        security_custom_ports:
          - port: 80
            protocol: tcp
            state: enabled
          - port: 443
            protocol: tcp
            state: enabled
          - port: 8080
            protocol: tcp
            state: enabled
          - port: 53
            protocol: udp
            state: enabled
```

## Advanced Examples

### Disable Specific Ports

```yaml
security_custom_ports:
  - port: 8080
    protocol: tcp
    state: disabled
```

### Multiple Protocols

```yaml
security_custom_ports:
  - port: 53
    protocol: tcp
    state: enabled
  - port: 53
    protocol: udp
    state: enabled
```

## Verification

After the role runs, verify firewall rules:

```bash
# List all open ports
sudo firewall-cmd --list-ports

# List all services
sudo firewall-cmd --list-services

# Check specific port
sudo firewall-cmd --query-port=22/tcp
```

## Handlers

- `firewalld reloaded`: Reloads firewalld configuration after changes

## Tags

- `security`: All security role tasks
- `firewall`: Firewall-related tasks
- `ssh`: SSH port configuration
- `custom-ports`: Custom port configuration

## Author

Parinya Luangchaisuk

## License

MIT-0
