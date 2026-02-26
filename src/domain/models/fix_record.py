# SPDX-License-Identifier: MIT-0
"""Fix record value object.

Pure Python - no external dependencies.
"""

from dataclasses import dataclass
from datetime import datetime
from enum import Enum


class FixStatus(Enum):
    """Status of a fix attempt."""

    SUCCESS = "success"
    FAILED = "failed"
    TIMEOUT = "timeout"


@dataclass(frozen=True)
class FixRecord:
    """Record of a self-healing fix attempt.

    This is a Value Object - immutable record of what happened.
    """

    iteration: int
    status: FixStatus
    timestamp: datetime = None
    error_context: str = ""
    claude_output: str = ""

    def __post_init__(self):
        """Set timestamp if not provided."""
        if self.timestamp is None:
            object.__setattr__(self, "timestamp", datetime.now())

    @property
    def was_successful(self) -> bool:
        """Check if fix was successful."""
        return self.status == FixStatus.SUCCESS
