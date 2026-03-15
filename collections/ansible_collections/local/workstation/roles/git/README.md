# Git Configuration Role

Configures git with comprehensive settings including identity, signing, workflow, and aliases.

## Features

* Idempotent git configuration
* SSH key detection: only enables signing if key exists
* Safe defaults: no hard requirements, won't fail if SSH key is missing
* User-specific configuration (configurable)
* Comprehensive git workflow optimization

## Role Variables

### Required (defaults provided)

* `git_config_user` - User account to configure (defaults to `ansible_user_id`)
* `git_config_name` - Git user name
* `git_config_email` - Git user email

### Identity Configuration

* `git_config_name` - User name (default: `parinya-ao`)
* `git_config_email` - User email (default: `flim.parinya.ao@gmail.com`)

### Commit Configuration

* `git_commit_verbose` - Enable verbose commit messages (default: `true`)
* `git_commit_gpgsign` - Enable commit signing (default: `true`, requires SSH key)

### Push/Pull Configuration

* `git_push_autosetupremote` - Auto-setup remote on push (default: `true`)
* `git_pull_rebase` - Use rebase instead of merge on pull (default: `true`)

### Rebase Configuration

* `git_rebase_autostash` - Auto-stash on rebase (default: `true`)

### Fetch Configuration

* `git_fetch_prune` - Auto-prune deleted remote branches (default: `true`)

### Rerere Configuration (Reuse Recorded Resolution)

* `git_rerere_enabled` - Enable rerere (default: `true`)
* `git_rerere_autoupdate` - Auto-update rerere database (default: `true`)

### Core Configuration

* `git_core_autocrlf` - CRLF handling (default: `input`)
* `git_core_editor` - Default editor (default: `nvim`)

### SSH Signing Configuration (Conditional)

* `git_ssh_pubkey_path` - Path to SSH public key (default: `~/.ssh/id_ed25519.pub`)
  * If file exists → enables SSH signing
  * If missing → skips signing configuration gracefully

### Aliases

* `git_alias_lg` - Graph log alias (default: `log --oneline --graph --decorate --all`)

### Other

* `git_config_scope` - Config scope, `global` or `local` (default: `global`)

## Behavior

### With SSH Key Present

Sets all configurations including:
* `user.name`, `user.email`
* `user.signingkey`, `gpg.format=ssh`, `commit.gpgsign=true`
* All workflow and core configurations

### Without SSH Key

Sets all configurations except signing-related:
* `user.name`, `user.email`
* Workflow and core configurations
* Skips `user.signingkey`, `gpg.format`, and `commit.gpgsign`

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
        git_core_editor: "vim"
```

## Configuration Reference

Resulting git config when all settings applied:

```
user.name = parinya-ao
user.email = flim.parinya.ao@gmail.com
user.signingkey = ~/.ssh/id_ed25519.pub
commit.gpgsign = true
commit.verbose = true
push.autosetupremote = true
pull.rebase = true
rebase.autostash = true
fetch.prune = true
rerere.enabled = true
rerere.autoupdate = true
core.autocrlf = input
core.editor = nvim
gpg.format = ssh
alias.lg = log --oneline --graph --decorate --all
```

## License

MIT-0
