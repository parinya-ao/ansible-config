# SPDX-License-Identifier: MIT-0
"""Domain models for Autonomous Agent.

These are pure Python objects (POPOs) - no external dependencies.
Only use: dataclasses, typing, uuid, datetime, enum
"""

from src.domain.models.agent_state import AgentState, AgentPhase
from src.domain.models.test_result import TestResult, TestPhase, TestStatus
from src.domain.models.fix_record import FixRecord, FixStatus
from src.domain.models.agent_config import AgentConfig

__all__ = [
    "AgentState",
    "AgentPhase",
    "TestResult",
    "TestPhase",
    "TestStatus",
    "FixRecord",
    "FixStatus",
    "AgentConfig",
]
