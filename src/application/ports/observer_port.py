# SPDX-License-Identifier: MIT-0
"""Observer Port - Interface for logging and monitoring.

This is a Port (Interface) in Hexagonal Architecture.
Infrastructure adapters will implement this for console, file, etc.
"""

from abc import ABC, abstractmethod
from enum import Enum

from src.domain.models import AgentState, TestResult, FixRecord


class LogLevel(Enum):
    """Log levels."""

    DEBUG = "debug"
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class ObserverPort(ABC):
    """Port for observing and logging agent activities.

    Abstract interface that defines HOW observations should be reported.
    Concrete implementations (ConsoleObserver, FileObserver, etc.)
    are in the infrastructure layer.
    """

    @abstractmethod
    def log(self, level: LogLevel, message: str) -> None:
        """Log a message."""
        pass

    @abstractmethod
    def on_iteration_start(self, iteration: int, max_retries: int) -> None:
        """Called when a new iteration starts."""
        pass

    @abstractmethod
    def on_iteration_complete(self, iteration: int, success: bool) -> None:
        """Called when an iteration completes."""
        pass

    @abstractmethod
    def on_test_start(self, phase: str) -> None:
        """Called when a test phase starts."""
        pass

    @abstractmethod
    def on_test_complete(self, result: TestResult) -> None:
        """Called when a test phase completes."""
        pass

    @abstractmethod
    def on_healing_start(self, iteration: int) -> None:
        """Called when healing starts."""
        pass

    @abstractmethod
    def on_healing_complete(self, fix_record: FixRecord) -> None:
        """Called when healing completes."""
        pass

    @abstractmethod
    def on_phase_change(self, phase: str) -> None:
        """Called when agent phase changes."""
        pass

    @abstractmethod
    def on_summary(self, summary: dict) -> None:
        """Called to display final summary."""
        pass
