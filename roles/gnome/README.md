GNOME Configuration Role
========================

This role configures the GNOME desktop environment using `dconf`. It allows for granular control over GNOME settings through a structured variable list.

Requirements
------------

- `community.general` collection (for `dconf` module)
- Fedora-based distribution (uses `dnf`)

Role Variables
--------------

The main variable to configure is `gnome_dconf_settings`. It is a list of objects, where each object defines a path and a set of key-value pairs.

### Variable Structure

```yaml
gnome_dconf_settings:
  - path: /org/gnome/desktop/interface/
    values:
      color-scheme: "'prefer-dark'"
      font-name: "'Inter 11'"
```

**Note:** Strings must be enclosed in single quotes inside the value (e.g. `"'value'"`) as per dconf requirements.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: localhost
  roles:
    - role: gnome
      vars:
        gnome_dconf_settings:
          - path: /org/gnome/desktop/interface/
            values:
              accent-color: "'teal'"
```

License
-------

MIT

Author Information
------------------

Parinya
