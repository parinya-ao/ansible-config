# SPDX-License-Identifier: MIT-0
"""Agent configuration value object.

Pure Python - no external dependencies.
"""

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class AgentConfig:
    """Configuration for the Autonomous Agent.

    This is a Value Object - immutable and defined by its attributes.
    """

    scenario: str
    max_retries: int
    skip_final: bool
    project_root: Path
    verbose: bool = False

    # Default scenario name
    DEFAULT_SCENARIO: str = "default"

    # Default max retries
    DEFAULT_MAX_RETRIES: int = 10

    def __post_init__(self):
        """Validate configuration."""
        if self.max_retries < 1:
            raise ValueError("max_retries must be at least 1")

        if not self.project_root.exists():
            raise ValueError(f"Project root does not exist: {self.project_root}")

    @classmethod
    def create(
        cls,
        scenario: str = DEFAULT_SCENARIO,
        max_retries: int = DEFAULT_MAX_RETRIES,
        skip_final: bool = False,
        project_root: Path | None = None,
        verbose: bool = False,
    ) -> "AgentConfig":
        """Factory method to create AgentConfig with defaults."""
        if project_root is None:
            project_root = Path.cwd()

        return cls(
            scenario=scenario,
            max_retries=max_retries,
            skip_final=skip_final,
            project_root=project_root,
            verbose=verbose,
        )
