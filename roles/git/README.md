# Git Configuration Role

Configures git with identity information and optional SSH signing support.

## Features

* Idempotent git configuration
* SSH key detection: only enables signing if key exists
* Safe defaults: no hard requirements, won't fail if SSH key is missing
* User-specific configuration (configurable)

## Role Variables

### Required (defaults provided)

* `git_config_user` - User account to configure (defaults to `ansible_user_id`)
* `git_config_name` - Git user name
* `git_config_email` - Git user email

### Optional

* `git_ssh_pubkey_path` - Path to SSH public key (default: `~/.ssh/id_ed25519.pub`)
  * If file exists → enables SSH signing
  * If missing → skips signing configuration gracefully
* `git_push_autosetupremote` - Auto-setup remote tracking (default: `true`)
* `git_config_scope` - Config scope, `global` or `local` (default: `global`)

## Behavior

### With SSH Key Present

Sets:
* `user.name`
* `user.email`
* `user.signingkey` (SSH public key path)
* `gpg.format=ssh`
* `commit.gpgsign=true`
* `push.autosetupremote=true`

### Without SSH Key

Sets only:
* `user.name`
* `user.email`
* `push.autosetupremote=true`

## Dependencies

Requires `community.general` collection for `git_config` module.

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - role: git
      vars:
        git_config_name: "John Doe"
        git_config_email: "john@example.com"
```

## License

MIT-0
