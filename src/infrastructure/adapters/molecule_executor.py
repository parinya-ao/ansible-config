# SPDX-License-Identifier: MIT-0
"""Molecule Executor Adapter.

Concrete implementation of ExecutorPort using Molecule CLI.
This adapter knows HOW to execute Molecule commands.
"""

import subprocess
from typing import List

from src.domain.models import TestResult, TestPhase, TestStatus
from src.application.ports import ExecutorPort
from src.infrastructure.config import Settings


class MoleculeExecutorAdapter(ExecutorPort):
    """Adapter for executing Molecule tests.

    Implements ExecutorPort using subprocess to call molecule CLI.
    """

    def __init__(self, scenario: str, env: dict, project_root):
        """Initialize the executor.

        Args:
            scenario: Molecule scenario name
            env: Environment variables for execution
            project_root: Path to project root
        """
        self.scenario = scenario
        self.env = env
        self.project_root = project_root

    def _run_command(
        self,
        command: List[str],
        phase: TestPhase,
    ) -> TestResult:
        """Run a command and return TestResult.

        Args:
            command: Command and arguments
            phase: Test phase for this execution

        Returns:
            TestResult with status and output
        """
        full_output = []

        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                env=self.env,
                cwd=str(self.project_root),
            )

            # Stream output
            for line in iter(process.stdout.readline, ""):
                if not line:
                    break
                clean_line = line.rstrip()
                if clean_line:
                    # Use observer for streaming (pass to console)
                    print(f"  │ {clean_line}")
                    full_output.append(clean_line)

            process.wait()
            returncode = process.returncode
            output = "\n".join(full_output)

            status = TestStatus.SUCCESS if returncode == 0 else TestStatus.FAILED

            return TestResult(
                phase=phase,
                status=status,
                return_code=returncode,
                output=output,
            )

        except Exception as e:
            return TestResult(
                phase=phase,
                status=TestStatus.FAILED,
                return_code=-1,
                output=f"Exception: {e}",
            )

    def create_containers(self) -> TestResult:
        """Create test containers."""
        return self._run_command(
            ["molecule", "create", "-s", self.scenario],
            TestPhase.CREATE,
        )

    def prepare_environment(self) -> TestResult:
        """Prepare test environment."""
        return self._run_command(
            ["molecule", "prepare", "-s", self.scenario],
            TestPhase.PREPARE,
        )

    def converge(self) -> TestResult:
        """Run converge (apply playbook)."""
        return self._run_command(
            ["molecule", "converge", "-s", self.scenario],
            TestPhase.CONVERGE,
        )

    def check_idempotence(self) -> TestResult:
        """Check idempotence."""
        return self._run_command(
            ["molecule", "idempotence", "-s", self.scenario],
            TestPhase.IDEMPOTENCE,
        )

    def verify(self) -> TestResult:
        """Run verification tests."""
        return self._run_command(
            ["molecule", "verify", "-s", self.scenario],
            TestPhase.VERIFY,
        )

    def run_full_test(self) -> TestResult:
        """Run complete test suite."""
        return self._run_command(
            ["molecule", "test", "-s", self.scenario],
            TestPhase.FULL_TEST,
        )

    def destroy_containers(self) -> TestResult:
        """Destroy all containers."""
        return self._run_command(
            ["molecule", "destroy", "-s", self.scenario],
            TestPhase.DESTROY,
        )

    def cleanup(self) -> TestResult:
        """Cleanup temporary files."""
        return self._run_command(
            ["molecule", "cleanup", "-s", self.scenario],
            TestPhase.CLEANUP,
        )

    def get_scenario_name(self) -> str:
        """Get the current scenario name."""
        return self.scenario
