# SPDX-License-Identifier: MIT-0
"""Claude Healer Adapter.

Concrete implementation of HealerPort using Claude Code CLI.
This adapter knows HOW to invoke Claude for self-healing.
"""

import os
import re
import subprocess
from typing import List
from pathlib import Path

from src.domain.models import FixRecord, FixStatus, AgentState
from src.application.ports import HealerPort
from src.infrastructure.config import Settings


class ClaudeHealerAdapter(HealerPort):
    """Adapter for self-healing using Claude Code CLI.

    Implements HealerPort by invoking claude CLI subprocess.
    """

    def __init__(
        self,
        claude_path: str = None,
        timeout: int = None,
        project_root: Path = None,
    ):
        """Initialize the healer.

        Args:
            claude_path: Path to claude CLI (default: from Settings)
            timeout: Timeout in seconds (default: from Settings)
            project_root: Project root directory
        """
        self.claude_path = claude_path or Settings.CLAUDE_CLI_PATH
        self.timeout = timeout or Settings.CLAUDE_TIMEOUT
        self.project_root = project_root or Settings.PROJECT_ROOT
        self.prompt_file = self.project_root / ".claude-heal-prompt.txt"

    def is_available(self) -> bool:
        """Check if Claude CLI is available."""
        try:
            result = subprocess.run(
                [self.claude_path, "--version"],
                capture_output=True,
                timeout=5,
            )
            return result.returncode == 0
        except Exception:
            return False

    def get_healer_name(self) -> str:
        """Get the name of this healer implementation."""
        return "Claude Code"

    def _extract_error_context(self, output: str, max_lines: int = 200) -> str:
        """Extract relevant error context from output.

        Args:
            output: Full output from failed test
            max_lines: Maximum lines to return

        Returns:
            Relevant error context
        """
        lines = output.splitlines()

        # Find error indicators
        error_patterns = [
            r"FAILED",
            r"ERROR",
            r"fatal:",
            r"Task/.*failed",
            r"changed=.*failed=1",
            r"Traceback",
            r"Exception",
        ]

        relevant_lines = []
        for i, line in enumerate(lines):
            if any(re.search(pattern, line, re.IGNORECASE) for pattern in error_patterns):
                # Include context around error
                start = max(0, i - 10)
                end = min(len(lines), i + 10)
                relevant_lines.extend(lines[start:end])
                break

        # If no specific error found, return last N lines
        if not relevant_lines:
            return "\n".join(lines[-max_lines:])

        return "\n".join(relevant_lines[-max_lines:])

    def _build_prompt(
        self,
        error_output: str,
        iteration: int,
        state: AgentState,
    ) -> str:
        """Build the prompt for Claude.

        Args:
            error_output: Error output
            iteration: Current iteration
            state: Agent state

        Returns:
            Prompt string for Claude
        """
        error_context = self._extract_error_context(error_output)

        prompt = f"""AUTONOMOUS ANSIBLE HEALING PROTOCOL

You are a self-healing Ansible agent with FULL WRITE ACCESS to the codebase.

## Context
- Iteration: {iteration}/{state.config.max_retries}
- Total fixes applied so far: {state.total_fixes_applied}
- Scenario: {state.config.scenario}

## Your Mission
Analyze the Ansible/Molecule error below and FIX THE ROOT CAUSE directly.

## Error Output
```
{error_context}
```

## Fixing Guidelines
1. DO NOT explain - just fix the code
2. Ensure idempotency - tasks should not repeat changes
3. Skip preflight checks in container environments: `common_skip_preflight: true`
4. For container testing, set these vars:
   - `common_enable_rpm_fusion: false`
   - `common_install_nvidia_drivers: false`
   - `common_configure_custom_dns: false`
   - `locale_install_gui_tools: false`
5. Handle systemd-dependent tasks gracefully (use `when: not container_detect`)
6. If a role fails, check the role's tasks/handlers for errors
7. Update defaults/main.yml if needed for container compatibility

## Working Directory
{self.project_root}

## Project Info
This is a Fedora Workstation Ansible configuration project.
Roles are in: {self.project_root}/roles/
Main playbook: {self.project_root}/playbook.yaml

Apply the fixes now. Exit when done.
"""
        return prompt

    def analyze_and_fix(
        self,
        error_output: str,
        iteration: int,
        state: AgentState,
    ) -> FixRecord:
        """Analyze error and invoke Claude to fix it.

        Args:
            error_output: Error output from failed test
            iteration: Current iteration number
            state: Current agent state

        Returns:
            FixRecord with status and details
        """
        prompt = self._build_prompt(error_output, iteration, state)

        # Save prompt to temp file
        self.prompt_file.write_text(prompt)

        try:
            # Invoke Claude Code
            result = subprocess.run(
                [self.claude_path, "-y", str(self.prompt_file)],
                text=True,
                capture_output=True,
                cwd=str(self.project_root),
                timeout=self.timeout,
            )

            if result.returncode == 0:
                return FixRecord(
                    iteration=iteration,
                    status=FixStatus.SUCCESS,
                    claude_output=result.stdout or "",
                    error_context=error_output[:200],
                )
            else:
                return FixRecord(
                    iteration=iteration,
                    status=FixStatus.FAILED,
                    claude_output=result.stderr or "Claude failed",
                    error_context=error_output[:200],
                )

        except subprocess.TimeoutExpired:
            return FixRecord(
                iteration=iteration,
                status=FixStatus.TIMEOUT,
                claude_output="Claude timed out",
                error_context=error_output[:200],
            )
        except Exception as e:
            return FixRecord(
                iteration=iteration,
                status=FixStatus.FAILED,
                claude_output=f"Exception: {e}",
                error_context=error_output[:200],
            )
        finally:
            # Clean up prompt file
            self.prompt_file.unlink(missing_ok=True)
