# SPDX-License-Identifier: MIT-0
"""Infrastructure configuration.

Settings and environment setup for infrastructure adapters.
"""

import os
from pathlib import Path
from typing import Dict


class Settings:
    """Infrastructure settings.

    Reads from environment variables with sensible defaults.
    """

    # Molecule settings
    MOLECULE_SCENARIO: str = os.getenv("MOLECULE_SCENARIO", "default")
    MOLECULE_TIMEOUT: int = int(os.getenv("MOLECULE_TIMEOUT", "300"))  # 5 minutes

    # Claude settings
    CLAUDE_CLI_PATH: str = os.getenv("CLAUDE_CLI_PATH", "claude")
    CLAUDE_TIMEOUT: int = int(os.getenv("CLAUDE_TIMEOUT", "300"))  # 5 minutes

    # Project settings
    PROJECT_ROOT: Path = Path(os.getenv("PROJECT_ROOT", "/home/parinya/personal/ansible-config"))

    # Ansible settings
    ANSIBLE_VERBOSITY: str = os.getenv("ANSIBLE_VERBOSITY", "1")
    ANSIBLE_FORCE_COLOR: str = os.getenv("ANSIBLE_FORCE_COLOR", "true")

    # Logging settings
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_COLORS: bool = os.getenv("LOG_COLORS", "true").lower() == "true"

    @classmethod
    def get_ansible_env(cls) -> Dict[str, str]:
        """Get environment variables for Ansible/Molecule execution."""
        env = os.environ.copy()

        # Remove conflicting Vault variables
        for var in ["ANSIBLE_VAULT_PASSWORD_FILE", "VAULT_PASSWORD_FILE"]:
            env.pop(var, None)

        # Set Ansible options
        env["ANSIBLE_FORCE_COLOR"] = cls.ANSIBLE_FORCE_COLOR
        env["PY_COLORS"] = "true"
        env["ANSIBLE_VERBOSITY"] = cls.ANSIBLE_VERBOSITY
        env["CI"] = "true"

        return env

    @classmethod
    def set_project_root(cls, path: Path) -> None:
        """Set project root path."""
        cls.PROJECT_ROOT = path
