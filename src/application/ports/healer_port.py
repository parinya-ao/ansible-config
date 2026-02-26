# SPDX-License-Identifier: MIT-0
"""Healer Port - Interface for self-healing.

This is a Port (Interface) in Hexagonal Architecture.
Infrastructure adapters will implement this for Claude Code, AI, etc.
"""

from abc import ABC, abstractmethod
from typing import Optional

from src.domain.models import FixRecord


class HealerPort(ABC):
    """Port for self-healing capabilities.

    Abstract interface that defines HOW errors should be healed.
    Concrete implementations (ClaudeHealer, OpenAIHealer, etc.)
    are in the infrastructure layer.
    """

    @abstractmethod
    def analyze_and_fix(
        self,
        error_output: str,
        iteration: int,
        state: "AgentState",
    ) -> FixRecord:
        """Analyze error and attempt to fix it.

        Args:
            error_output: The error output from failed test
            iteration: Current iteration number
            state: Current agent state

        Returns:
            FixRecord with status and details
        """
        pass

    @abstractmethod
    def is_available(self) -> bool:
        """Check if healer is available (e.g., Claude CLI installed)."""
        pass

    @abstractmethod
    def get_healer_name(self) -> str:
        """Get the name of this healer implementation."""
        pass
