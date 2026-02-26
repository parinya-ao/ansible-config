# SPDX-License-Identifier: MIT-0
"""Agent state entity.

Pure Python - no external dependencies.
This is an Entity - it has identity and lifecycle.
"""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import List


class AgentPhase(Enum):
    """Agent execution phases."""

    INITIALIZATION = "initialization"
    INITIAL_VALIDATION = "initial_validation"
    CLEAN_ROOM_VALIDATION = "clean_room_validation"
    FINALIZATION = "finalization"
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class AgentState:
    """State of the Autonomous Agent.

    This is an Entity - it has identity (the session) and mutable state.
    Tracks the agent's progress through testing and healing cycles.
    """

    config: "AgentConfig"
    current_iteration: int = 0
    current_phase: AgentPhase = AgentPhase.INITIALIZATION
    total_fixes_applied: int = 0
    errors_encountered: List[dict] = field(default_factory=list)
    fix_history: List[dict] = field(default_factory=list)
    start_time: datetime = field(default_factory=datetime.now)
    end_time: datetime | None = None

    def transition_to(self, phase: AgentPhase) -> None:
        """Transition to a new phase."""
        self.current_phase = phase

    def increment_iteration(self) -> int:
        """Increment iteration counter and return new value."""
        self.current_iteration += 1
        return self.current_iteration

    def record_error(self, phase: str, error_message: str) -> None:
        """Record an error for tracking."""
        self.errors_encountered.append({
            "iteration": self.current_iteration,
            "phase": phase,
            "timestamp": datetime.now().isoformat(),
            "error": error_message[:500],  # Truncate long errors
        })

    def record_fix(self, iteration: int, success: bool) -> None:
        """Record a fix attempt."""
        self.fix_history.append({
            "iteration": iteration,
            "timestamp": datetime.now().isoformat(),
            "success": success,
        })
        if success:
            self.total_fixes_applied += 1

    def is_final_iteration(self) -> bool:
        """Check if this is the final allowed iteration."""
        return self.current_iteration >= self.config.max_retries

    def can_retry(self) -> bool:
        """Check if agent can attempt another retry."""
        return self.current_iteration < self.config.max_retries

    def mark_completed(self) -> None:
        """Mark agent as completed successfully."""
        self.end_time = datetime.now()
        self.current_phase = AgentPhase.COMPLETED

    def mark_failed(self) -> None:
        """Mark agent as failed."""
        self.end_time = datetime.now()
        self.current_phase = AgentPhase.FAILED

    def get_duration_seconds(self) -> float:
        """Get duration in seconds."""
        end = self.end_time or datetime.now()
        return (end - self.start_time).total_seconds()

    def get_summary(self) -> dict:
        """Get a summary of the agent's run."""
        return {
            "scenario": self.config.scenario,
            "total_iterations": self.current_iteration,
            "total_fixes": self.total_fixes_applied,
            "duration_seconds": self.get_duration_seconds(),
            "errors_count": len(self.errors_encountered),
            "success": self.current_phase == AgentPhase.COMPLETED,
            "phase": self.current_phase.value,
        }
