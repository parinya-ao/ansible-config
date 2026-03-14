# Molecule Testing Guide

## Overview

This project uses **Molecule** with the **ansible-native approach** for testing Ansible playbooks and roles. The testing framework is configured for **Fedora Rawhide** (rolling development branch) with **DNF5** and **Python 3.13+**.

## Directory Structure

```
extensions/molecule/
├── config.yml              # Base configuration (inherited by all scenarios)
├── inventory.yml           # Shared test inventory
├── requirements.yml        # Collection dependencies for testing
├── default/                # Lifecycle manager scenario
│   ├── molecule.yml
│   ├── create.yml         # Initialize shared resources
│   └── destroy.yml        # Clean up shared resources
└── sample-component/       # Example component scenario
    ├── molecule.yml
    ├── prepare.yml        # Install prerequisites
    ├── converge.yml       # Execute component under test
    ├── verify.yml         # Validate results
    └── cleanup.yml        # Remove test artifacts
```

## Quick Start

### Run All Tests

```bash
# Run all scenarios with shared state (recommended)
molecule test --all --shared-state --report --command-borders

# Run specific scenario
molecule test --scenario-name sample-component
```

### Development Workflow

```bash
# Create resources once
molecule create --scenario-name default

# Run component tests
molecule converge --scenario-name sample-component
molecule verify --scenario-name sample-component

# Test idempotence
molecule idempotence --scenario-name sample-component

# Clean up
molecule destroy --scenario-name default
```

## CI/CD Integration

### GitHub Actions

The pipeline is configured in `.github/workflows/molecule.yml`:

- **Stage 1**: Lint and validate (yamllint, ansible-lint)
- **Stage 2**: Molecule tests on Fedora Rawhide (parallel scenarios)
- **Stage 3**: Integration test (all scenarios with shared state)
- **Stage 4**: Success validation

### GitLab CI

The pipeline is configured in `.gitlab-ci.yml`:

- **validate**: YAML and Ansible linting
- **molecule-test**: Parallel scenario testing
- **molecule-integration**: Full integration test
- **deploy**: Optional deployment stage

## Configuration

### Base Configuration (config.yml)

All scenarios inherit from `config.yml`:

```yaml
ansible:
  executor:
    backend: ansible-playbook
    args:
      ansible_playbook:
        - --inventory=${MOLECULE_SCENARIO_DIRECTORY}/../inventory.yml
  env:
    ANSIBLE_FORCE_COLOR: "true"
  cfg:
    defaults:
      fact_caching: memory
      gathering: smart

scenario:
  test_sequence:
    - prepare
    - converge
    - verify
    - idempotence
    - verify
    - cleanup

shared_state: true  # Enable shared resources
```

### Shared State

With `shared_state: true`:

1. **default scenario** runs `create` first (initializes resources)
2. **Component scenarios** run tests (prepare, converge, verify, cleanup)
3. **default scenario** runs `destroy` last (cleans up resources)

This avoids repeated create/destroy cycles for each scenario.

## Creating New Scenarios

### 1. Create Scenario Directory

```bash
mkdir -p extensions/molecule/my-scenario
touch extensions/molecule/my-scenario/molecule.yml  # Empty = inherits config.yml
```

### 2. Create Playbooks

**prepare.yml** - Install prerequisites:
```yaml
---
- name: Prepare test environment
  hosts: test_resources
  tasks:
    - name: Install packages
      ansible.builtin.dnf:
        name: "{{ prerequisites | default([]) }}"
        state: present
```

**converge.yml** - Execute component:
```yaml
---
- name: Test collection component
  hosts: test_resources
  tasks:
    - name: Include role
      ansible.builtin.include_role:
        name: my_namespace.my_collection.my_role
```

**verify.yml** - Validate results:
```yaml
---
- name: Verify functionality
  hosts: test_resources
  tasks:
    - name: Check service
      ansible.builtin.assert:
        that:
          - service_is_running
```

**cleanup.yml** - Remove artifacts:
```yaml
---
- name: Cleanup
  hosts: test_resources
  tasks:
    - name: Remove test files
      ansible.builtin.file:
        path: /tmp/test-file
        state: absent
```

### 3. Run Scenario

```bash
molecule test --scenario-name my-scenario
```

## Inventory

The shared inventory (`inventory.yml`) defines test resources:

```yaml
all:
  vars:
    tmp_dir: "{{ lookup('env', 'TMPDIR') | default('/tmp') }}"
  
  children:
    test_resources:
      hosts:
        test-host-1:
          ansible_connection: local
          my_variable: test_host_1
        test-host-2:
          ansible_connection: local
          my_variable: test_host_2
```

## Fedora Rawhide Specifics

### DNF5

Fedora Rawhide uses DNF5 as the default package manager:

```yaml
ansible_pkg_mgr: dnf5
```

### Python 3.13+

The CI uses Python 3.13 or newer:

```bash
python3 --version  # 3.13+
```

### Podman

Container testing uses Podman (not Docker):

```yaml
collections:
  - name: containers.podman
    version: ">=1.10.0"
```

## Troubleshooting

### View Molecule Logs

```bash
# List scenarios
molecule list

# View logs
ls -la .cache/molecule/*/logs/
```

### Debug Mode

```bash
# Run with verbose output
molecule test --scenario-name sample-component -vvv

# Keep resources after test
molecule test --destroy=never
```

### Common Issues

**DNF5 not found**: Ensure you're running on Fedora 41+ or Rawhide

**Python version mismatch**: Use `python3` explicitly, not `python`

**Permission denied**: Run with `--privileged` in container mode

## Best Practices

1. **Use shared_state**: Faster execution, single lifecycle
2. **Keep playbooks idempotent**: Test with `molecule idempotence`
3. **Clean up properly**: Remove all test artifacts in cleanup.yml
4. **Use local connection**: For unit testing without containers
5. **Test on Rawhide**: Catch issues early before Fedora releases

## References

- [Molecule Documentation](https://ansible.readthedocs.io/projects/molecule/)
- [Ansible Native Configuration](https://ansible.readthedocs.io/projects/molecule/using/ansible-native/)
- [Fedora Rawhide](https://fedoraproject.org/wiki/Releases/Rawhide)
