# SPDX-License-Identifier: MIT-0
"""Autonomous Agent Use Case.

This is the orchestrator that coordinates all operations.
Uses ports (interfaces) to interact with external systems.
Following Hexagonal Architecture: Use Case → Ports → Adapters
"""

import time
from typing import Optional

from src.domain import (
    AgentConfig,
    AgentPhase,
    AgentState,
    TestStatus,
)
from src.domain.exceptions import (
    ContainerCreationError,
    MaxRetriesExceededError,
)

from src.application.ports import (
    ExecutorPort,
    HealerPort,
    ObserverPort,
    LogLevel,
)


class AutonomousAgentUseCase:
    """Main use case for autonomous testing agent.

    This use case orchestrates the entire testing and healing process.
    It depends on abstractions (Ports), not concrete implementations.
    """

    def __init__(
        self,
        config: AgentConfig,
        executor: ExecutorPort,
        healer: HealerPort,
        observer: ObserverPort,
    ):
        """Initialize the use case with required dependencies.

        Args:
            config: Agent configuration
            executor: Port for test execution
            healer: Port for self-healing
            observer: Port for logging/observation
        """
        self.config = config
        self.executor = executor
        self.healer = healer
        self.observer = observer
        self.state = AgentState(config=config)

        self.observer.log(
            LogLevel.INFO,
            f"Initialized AutonomousAgent with scenario '{config.scenario}'"
        )

    def run(self) -> bool:
        """Run the full autonomous agent workflow.

        Returns:
            True if all tests passed, False otherwise
        """
        try:
            # Phase 1: Initial validation with self-healing
            if not self._run_initial_validation():
                self._finalize(success=False)
                return False

            # Phase 2: Clean-room final validation
            if not self._run_clean_room_validation():
                self._finalize(success=False)
                return False

            # Success!
            self._finalize(success=True)
            return True

        except Exception as e:
            self.observer.log(LogLevel.CRITICAL, f"Fatal error: {e}")
            self._finalize(success=False)
            return False

    def _run_initial_validation(self) -> bool:
        """Phase 1: Initial validation with self-healing loop."""
        self.observer.on_phase_change("INITIAL_VALIDATION")
        self.state.transition_to(AgentPhase.INITIAL_VALIDATION)

        while self.state.can_retry():
            iteration = self.state.increment_iteration()

            self.observer.on_iteration_start(iteration, self.config.max_retries)

            # Attempt to run tests
            success = self._attempt_test_cycle(iteration)

            if success:
                self.observer.on_iteration_complete(iteration, success=True)
                self.observer.log(
                    LogLevel.INFO,
                    f"All tests passed in {iteration} iteration(s)"
                )
                return True

            # Failed - attempt healing
            self.observer.on_iteration_complete(iteration, success=False)

            if self.state.can_retry():
                self._attempt_healing(iteration)
                # Brief pause before retry
                time.sleep(2)
            else:
                self.observer.log(
                    LogLevel.ERROR,
                    f"Max retries ({self.config.max_retries}) exceeded"
                )
                return False

        return False

    def _attempt_test_cycle(self, iteration: int) -> bool:
        """Attempt a single test cycle.

        Returns:
            True if all tests passed, False otherwise
        """
        # Step 1: Create containers
        result = self.executor.create_containers()
        self.observer.on_test_complete(result)

        if not result.is_success():
            self.state.record_error("create", result.get_error_summary() or "Create failed")
            return False

        # Step 2: Prepare environment
        result = self.executor.prepare_environment()
        self.observer.on_test_complete(result)

        if not result.is_success():
            self.state.record_error("prepare", result.get_error_summary() or "Prepare failed")
            self.executor.destroy_containers()
            return False

        # Step 3: Run full test suite
        self.observer.log(LogLevel.INFO, "Running ALL tests (STRESS MODE)")
        result = self.executor.run_full_test()
        self.observer.on_test_complete(result)

        if result.is_success():
            return True

        # Failed
        self.state.record_error("full_test", result.get_error_summary() or "Test failed")
        self.executor.destroy_containers()
        self.executor.cleanup()
        return False

    def _attempt_healing(self, iteration: int) -> None:
        """Attempt to heal the current error."""
        self.observer.on_healing_start(iteration)

        # Get last error for healing
        last_error = self.state.errors_encountered[-1]
        error_output = last_error.get("error", "")

        # Invoke healer
        fix_record = self.healer.analyze_and_fix(
            error_output=error_output,
            iteration=iteration,
            state=self.state,
        )

        self.observer.on_healing_complete(fix_record)
        self.state.record_fix(iteration, fix_record.was_successful)

    def _run_clean_room_validation(self) -> bool:
        """Phase 2: Clean-room final validation."""
        if self.config.skip_final:
            self.observer.log(LogLevel.INFO, "Skipping final validation (--skip-final)")
            return True

        self.observer.on_phase_change("CLEAN_ROOM_VALIDATION")
        self.state.transition_to(AgentPhase.CLEAN_ROOM_VALIDATION)

        self.observer.log(LogLevel.INFO, "Destroying everything and starting fresh...")

        # Ensure clean state
        self.executor.destroy_containers()
        self.executor.cleanup()

        self.observer.log(LogLevel.INFO, "Waiting 3 seconds for containers to terminate...")
        time.sleep(3)

        self.observer.log(LogLevel.INFO, "Starting FINAL validation run...")

        # Run full test from scratch
        result = self.executor.run_full_test()
        self.observer.on_test_complete(result)

        if result.is_success():
            self.observer.log(LogLevel.INFO, "FINAL VALIDATION PASSED!")
            return True

        self.observer.log(LogLevel.ERROR, "FINAL VALIDATION FAILED")
        return False

    def _finalize(self, success: bool) -> None:
        """Finalize the agent run."""
        self.observer.on_phase_change("FINALIZATION")
        self.state.transition_to(AgentPhase.FINALIZATION)

        # Cleanup
        self.executor.destroy_containers()
        self.executor.cleanup()

        # Mark completion
        if success:
            self.state.mark_completed()
        else:
            self.state.mark_failed()

        # Display summary
        summary = self.state.get_summary()
        self.observer.on_summary(summary)

        self.observer.log(
            LogLevel.INFO,
            f"Agent {'succeeded' if success else 'failed'} "
            f"after {self.state.current_iteration} iterations"
        )
