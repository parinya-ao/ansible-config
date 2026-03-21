# SSH Role

Configures SSH directory and file permissions on Fedora systems.

## Overview

This role ensures proper SSH directory and file permissions for secure SSH operation:
- `~/.ssh/` directory: 700
- `~/.ssh/id_ed25519` (private key): 600
- `~/.ssh/id_ed25519.pub` (public key): 644
- `~/.ssh/authorized_keys`: 600

## Requirements

- Fedora Linux (any supported version)
- Ansible 2.9 or higher
- User must have a home directory

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ssh_dir` | `~/.ssh` | SSH directory path |
| `ssh_key_type` | `ed25519` | SSH key type |
| `ssh_private_key` | `~/.ssh/id_ed25519` | Private key path |
| `ssh_public_key` | `~/.ssh/id_ed25519.pub` | Public key path |
| `ssh_authorized_keys` | `~/.ssh/authorized_keys` | Authorized keys path |
| `ssh_dir_mode` | `0700` | SSH directory permissions |
| `ssh_private_key_mode` | `0600` | Private key permissions |
| `ssh_public_key_mode` | `0644` | Public key permissions |
| `ssh_authorized_keys_mode` | `0600` | Authorized keys permissions |
| `ssh_create_dir` | `true` | Create SSH directory if missing |
| `ssh_generate_key` | `false` | Generate SSH key if missing |
| `ssh_key_size` | `4096` | SSH key size (for RSA) |
| `ssh_key_comment` | `user@hostname` | SSH key comment |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: local.workstation.ssh
      tags:
        - ssh
        - security
```

### Generate SSH Key

```yaml
- hosts: all
  roles:
    - role: local.workstation.ssh
      vars:
        ssh_generate_key: true
        ssh_key_comment: "my-workstation-key"
```

## Tags

- `ssh` - Main tag for all SSH tasks
- `permissions` - Permission-related tasks
- `directory` - Directory creation tasks
- `generate` - Key generation tasks

## What This Role Does

1. **Creates SSH Directory** - Creates `~/.ssh/` with 700 permissions
2. **Sets Private Key Permissions** - Sets 600 on `id_ed25519`
3. **Sets Public Key Permissions** - Sets 644 on `id_ed25519.pub`
4. **Sets Authorized Keys Permissions** - Sets 600 on `authorized_keys`
5. **Optional: Generates SSH Key** - Creates new key pair if enabled

## Verification

After running this role:

```bash
# Check SSH directory permissions
ls -la ~/.ssh/

# Expected output:
# drwx------  2 user user 4096 Mar 21 10:00 .
# -rw-------  1 user user  411 Mar 21 10:00 id_ed25519
# -rw-r--r--  1 user user  102 Mar 21 10:00 id_ed25519.pub
# -rw-------  1 user user  200 Mar 21 10:00 authorized_keys
```

## Manual Commands (Without Ansible)

```bash
# Set SSH directory permissions
chmod 700 ~/.ssh

# Set private key permissions
chmod 600 ~/.ssh/id_ed25519

# Set public key permissions
chmod 644 ~/.ssh/id_ed25519.pub

# Set authorized_keys permissions
chmod 600 ~/.ssh/authorized_keys
```

## Troubleshooting

### SSH Key Not Working

1. **Check permissions:**
   ```bash
   ls -la ~/.ssh/
   ```

2. **Test SSH connection:**
   ```bash
   ssh -T git@github.com
   ```

3. **Check SELinux context (if applicable):**
   ```bash
   ls -Z ~/.ssh/
   restorecon -Rv ~/.ssh/
   ```

### Permission Denied Errors

If you get "Permission denied" errors, ensure:
- You own the files: `chown -R $USER:$USER ~/.ssh/`
- Permissions are correct (see above)
- SELinux is not blocking (check with `getenforce`)

## References

- [SSH Best Practices](https://www.ssh.com/academy/ssh/best-practices)
- [OpenSSH Key Management](https://www.openssh.com/manual.html)
- [Fedora SSH Guide](https://docs.fedoraproject.org/en-US/quick-docs/ssh-getting-started/)

## License

MIT

## Author

Your Name
