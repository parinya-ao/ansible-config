# SPDX-License-Identifier: MIT-0
"""Domain layer for Autonomous Agent.

Core business logic - NO external dependencies.
Only pure Python: dataclasses, typing, uuid, datetime, enum
"""

from src.domain.models import (
    AgentState,
    AgentPhase,
    AgentConfig,
    TestResult,
    TestPhase,
    TestStatus,
    FixRecord,
    FixStatus,
)

from src.domain.exceptions import (
    AgentError,
    MaxRetriesExceededError,
    TestExecutionError,
    HealingFailedError,
    ValidationError,
    ContainerCreationError,
    IdempotenceCheckError,
)

__all__ = [
    # Models
    "AgentState",
    "AgentPhase",
    "AgentConfig",
    "TestResult",
    "TestPhase",
    "TestStatus",
    "FixRecord",
    "FixStatus",
    # Exceptions
    "AgentError",
    "MaxRetriesExceededError",
    "TestExecutionError",
    "HealingFailedError",
    "ValidationError",
    "ContainerCreationError",
    "IdempotenceCheckError",
]
