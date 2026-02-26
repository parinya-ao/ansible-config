# SPDX-License-Identifier: MIT-0
"""Domain exceptions for Autonomous Agent.

Pure Python exceptions - no framework dependencies.
Follows DDD principle: Domain Layer must not depend on infrastructure.
"""


class AgentError(Exception):
    """Base exception for all domain errors."""

    pass


class MaxRetriesExceededError(AgentError):
    """Raised when agent exceeds maximum retry attempts."""

    def __init__(self, current_iteration: int, max_retries: int):
        self.current_iteration = current_iteration
        self.max_retries = max_retries
        super().__init__(
            f"Maximum retries exceeded: {current_iteration}/{max_retries}"
        )


class TestExecutionError(AgentError):
    """Raised when test execution fails."""

    def __init__(self, phase: str, return_code: int, output: str):
        self.phase = phase
        self.return_code = return_code
        self.output = output
        super().__init__(
            f"Test execution failed in phase '{phase}' with code {return_code}"
        )


class HealingFailedError(AgentError):
    """Raised when self-healing mechanism fails."""

    def __init__(self, reason: str):
        self.reason = reason
        super().__init__(f"Self-healing failed: {reason}")


class ValidationError(AgentError):
    """Raised when validation fails."""

    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"Validation error for '{field}': {message}")


class ContainerCreationError(AgentError):
    """Raised when container creation fails."""

    pass


class IdempotenceCheckError(AgentError):
    """Raised when idempotence check fails."""

    def __init__(self, changed_count: int, failed_count: int):
        self.changed_count = changed_count
        self.failed_count = failed_count
        super().__init__(
            f"Idempotence check failed: changed={changed_count}, failed={failed_count}"
        )
