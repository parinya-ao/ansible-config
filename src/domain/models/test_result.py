# SPDX-License-Identifier: MIT-0
"""Test result value object.

Pure Python - no external dependencies.
"""

from dataclasses import dataclass
from datetime import datetime
from enum import Enum


class TestPhase(Enum):
    """Test execution phases."""

    CREATE = "create"
    PREPARE = "prepare"
    CONVERGE = "converge"
    IDEMPOTENCE = "idempotence"
    VERIFY = "verify"
    FULL_TEST = "full_test"
    DESTROY = "destroy"
    CLEANUP = "cleanup"


class TestStatus(Enum):
    """Test execution status."""

    SUCCESS = "success"
    FAILED = "failed"
    SKIPPED = "skipped"


@dataclass(frozen=True)
class TestResult:
    """Result of a test execution.

    This is a Value Object - immutable and defined by its attributes.
    """

    phase: TestPhase
    status: TestStatus
    return_code: int
    output: str
    timestamp: datetime = None

    def __post_init__(self):
        """Set timestamp if not provided."""
        if self.timestamp is None:
            object.__setattr__(self, "timestamp", datetime.now())

    def is_success(self) -> bool:
        """Check if test was successful."""
        return self.status == TestStatus.SUCCESS

    def is_failure(self) -> bool:
        """Check if test failed."""
        return self.status == TestStatus.FAILED

    def get_error_summary(self) -> str | None:
        """Get error summary from output."""
        if self.is_success():
            return None

        lines = self.output.splitlines()
        # Find last ERROR or FAILED line
        for line in reversed(lines[-20:]):
            if "ERROR" in line or "FAILED" in line or "fatal:" in line:
                return line.strip()
        return self.output[:200]
