# Molecule Podman-Docker Scenario

This scenario tests Ansible configurations using **Podman as primary** and **Docker as secondary/redundancy** container runtimes.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Molecule Test Scenario                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Primary: Podman Containers                                  │
│  ┌──────────────────────────────────────────────┐           │
│  │ molecule-fedora-podman                       │           │
│  │ - Connection: containers.podman.podman       │           │
│  │ - Image: ghcr.io/ansible/...-dev-tools       │           │
│  └──────────────────────────────────────────────┘           │
│                                                              │
│  Secondary: Docker Containers (Redundancy)                   │
│  ┌──────────────────────────────────────────────┐           │
│  │ molecule-fedora-docker                       │           │
│  │ - Connection: community.docker.docker        │           │
│  │ - Image: ghcr.io/ansible/...-dev-tools       │           │
│  └──────────────────────────────────────────────┘           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
podman-docker/
├── molecule.yml              # Scenario configuration
├── requirements.yml          # Collection dependencies
├── create.yml               # Container creation playbook
├── converge.yml             # Configuration application playbook
├── verify.yml               # Validation playbook
├── cleanup.yml              # Cleanup temporary artifacts
├── destroy.yml              # Container destruction playbook
├── tasks/
│   └── create-fail.yml      # Error handling for creation failures
└── inventory/
    ├── 01-inventory.yml     # Static host definitions
    ├── 02-constructed.yml   # Dynamic group creation
    ├── group_vars/
    │   ├── molecule.yml              # Shared container vars
    │   ├── podman_containers.yml     # Podman-specific vars
    │   └── docker_containers.yml     # Docker-specific vars
    └── host_vars/
        ├── molecule-fedora-podman.yml
        └── molecule-fedora-docker.yml
```

## Usage

### Run Full Test Sequence

```bash
molecule test --scenario-name podman-docker
```

### Run Individual Steps

```bash
# Create containers
molecule create --scenario-name podman-docker

# Apply configuration
molecule converge --scenario-name podman-docker

# Verify configuration
molecule verify --scenario-name podman-docker

# Cleanup and destroy
molecule destroy --scenario-name podman-docker
```

### Debug Mode

```bash
molecule test --scenario-name podman-docker --destroy=never
```

## Key Features

### 1. Dual Runtime Support

- **Podman**: Primary runtime using `containers.podman` collection
- **Docker**: Secondary/redundancy runtime using `community.docker` collection

### 2. Native Ansible Inventory

- Static inventory (`01-inventory.yml`): Defines hosts and container images
- Constructed inventory (`02-constructed.yml`): Creates dynamic groups
- Group variables: Runtime-specific configuration
- Host variables: Host-specific environment variables

### 3. Dynamic Groups

The constructed plugin creates these groups automatically:

- `molecule`: All test containers
- `podman_containers`: Podman-based containers
- `docker_containers`: Docker-based containers

### 4. Error Handling

- Container creation failures include log retrieval
- Graceful degradation for missing runtimes
- Comprehensive error messages

## Configuration

### Container Images

Both runtimes use the same base image for consistency:

```yaml
container_image: ghcr.io/ansible/community-ansible-dev-tools:latest
```

### Environment Variables

Test containers include these environment variables:

- `MOLECULE_TEST_CONTAINER=true`
- `ANSIBLE_DEV_TOOLS_CONTAINER=1`
- `CI=true`
- `PY_COLORS=1`

### Security Settings

Containers run with minimal capabilities:

- `CHOWN`
- `SETUID`
- `SETGID`

No privileged mode by default.

## Extending

### Add More Containers

Edit `inventory/01-inventory.yml`:

```yaml
all:
  children:
    molecule:
      hosts:
        molecule-fedora-podman:
          container_image: ghcr.io/ansible/community-ansible-dev-tools:latest
          container_runtime: podman
        # Add more containers here
```

### Add Roles to Test

Edit `converge.yml`:

```yaml
roles:
  - role: common
  - role: locale
  - role: desktop
```

### Custom Container Settings

Edit `inventory/host_vars/<hostname>.yml`:

```yaml
container_env:
  CUSTOM_VAR: "value"
container_volumes:
  - /host/path:/container/path
container_capabilities:
  - NET_ADMIN
```

## Troubleshooting

### Podman Not Available

If Podman is not installed, the scenario will still create Docker containers.

### Docker Not Available

If Docker is not installed, the scenario will still create Podman containers.

### Container Creation Fails

Check logs with:

```bash
podman logs molecule-fedora-podman
docker logs molecule-fedora-docker
```

### Inventory Issues

Debug inventory with:

```bash
ansible-inventory -i molecule/podman-docker/inventory/ --list
```

## Requirements

- Podman and/or Docker installed
- Ansible collections (installed automatically):
  - `containers.podman >= 1.10.0`
  - `community.docker >= 3.10.4`

## License

MIT-0
