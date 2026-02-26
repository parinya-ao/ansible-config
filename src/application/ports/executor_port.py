# SPDX-License-Identifier: MIT-0
"""Executor Port - Interface for test execution.

This is a Port (Interface) in Hexagonal Architecture.
Infrastructure adapters will implement this for Molecule, Podman, etc.
"""

from abc import ABC, abstractmethod
from typing import Tuple

from src.domain.models import TestResult, TestPhase


class ExecutorPort(ABC):
    """Port for executing tests.

    Abstract interface that defines HOW tests should be executed.
    Concrete implementations (MoleculeExecutor, DockerExecutor, etc.)
    are in the infrastructure layer.
    """

    @abstractmethod
    def create_containers(self) -> TestResult:
        """Create test containers."""
        pass

    @abstractmethod
    def prepare_environment(self) -> TestResult:
        """Prepare test environment."""
        pass

    @abstractmethod
    def converge(self) -> TestResult:
        """Run converge (apply playbook)."""
        pass

    @abstractmethod
    def check_idempotence(self) -> TestResult:
        """Check idempotence."""
        pass

    @abstractmethod
    def verify(self) -> TestResult:
        """Run verification tests."""
        pass

    @abstractmethod
    def run_full_test(self) -> TestResult:
        """Run complete test suite."""
        pass

    @abstractmethod
    def destroy_containers(self) -> TestResult:
        """Destroy all containers."""
        pass

    @abstractmethod
    def cleanup(self) -> TestResult:
        """Cleanup temporary files."""
        pass

    @abstractmethod
    def get_scenario_name(self) -> str:
        """Get the current scenario name."""
        pass
