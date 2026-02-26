# SPDX-License-Identifier: MIT-0
"""Console Observer Adapter.

Concrete implementation of ObserverPort for console output.
This adapter knows HOW to display messages to the user.
"""

import logging
import sys
from typing import Optional

from src.domain.models import TestResult, FixRecord, AgentState
from src.application.ports import ObserverPort, LogLevel


class ConsoleObserverAdapter(ObserverPort):
    """Adapter for observing via console output.

    Implements ObserverPort using Python logging and colored output.
    """

    # ANSI Colors
    RESET = "\033[0m"
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    MAGENTA = "\033[0;35m"
    CYAN = "\033[0;36m"
    BOLD = "\033[1m"

    # Log level colors
    LEVEL_COLORS = {
        LogLevel.DEBUG: CYAN,
        LogLevel.INFO: GREEN,
        LogLevel.WARNING: YELLOW,
        LogLevel.ERROR: RED,
        LogLevel.CRITICAL: RED + BOLD,
    }

    def __init__(self, verbose: bool = False):
        """Initialize the observer.

        Args:
            verbose: Enable debug logging
        """
        self.verbose = verbose
        self._setup_logging()

    def _setup_logging(self):
        """Setup logging configuration."""
        level = logging.DEBUG if self.verbose else logging.INFO

        # Configure root logger
        logging.basicConfig(
            level=level,
            format="%(asctime)s [%(levelname)s] %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
            handlers=[logging.StreamHandler(sys.stdout)],
        )

        self.logger = logging.getLogger(__name__)

    def _colorize(self, message: str, color: str) -> str:
        """Add ANSI color to message.

        Args:
            message: Message to colorize
            color: ANSI color code

        Returns:
            Colorized message
        """
        return f"{color}{message}{self.RESET}"

    def log(self, level: LogLevel, message: str) -> None:
        """Log a message."""
        color = self.LEVEL_COLORS.get(level, "")
        colored_message = self._colorize(message, color)

        if level == LogLevel.DEBUG:
            self.logger.debug(colored_message)
        elif level == LogLevel.INFO:
            self.logger.info(colored_message)
        elif level == LogLevel.WARNING:
            self.logger.warning(colored_message)
        elif level == LogLevel.ERROR:
            self.logger.error(colored_message)
        elif level == LogLevel.CRITICAL:
            self.logger.critical(colored_message)

    def on_iteration_start(self, iteration: int, max_retries: int) -> None:
        """Called when a new iteration starts."""
        banner = f"╔══ ITERATION {iteration}/{max_retries} ══"
        self.log(LogLevel.INFO, self._colorize(banner, self.MAGENTA + self.BOLD))
        self.log(LogLevel.INFO, self._colorize("║", self.MAGENTA + self.BOLD))

    def on_iteration_complete(self, iteration: int, success: bool) -> None:
        """Called when an iteration completes."""
        status = "PASSED" if success else "FAILED"
        color = self.GREEN if success else self.RED
        self.log(LogLevel.INFO, self._colorize(f"Iteration {iteration}: {status}", color))

    def on_test_start(self, phase: str) -> None:
        """Called when a test phase starts."""
        self.log(LogLevel.INFO, self._colorize(f"▶ {phase}...", self.BOLD))

    def on_test_complete(self, result: TestResult) -> None:
        """Called when a test phase completes."""
        if result.is_success():
            self.log(LogLevel.INFO, self._colorize(f"✓ {result.phase.value} completed", self.GREEN))
        else:
            error_summary = result.get_error_summary() or "Unknown error"
            self.log(LogLevel.ERROR, self._colorize(
                f"✗ {result.phase.value} failed: {error_summary[:100]}",
                self.RED
            ))

    def on_healing_start(self, iteration: int) -> None:
        """Called when healing starts."""
        self.log(LogLevel.INFO, self._colorize(
            f"🤖 Invoking Claude Code Self-Healing (iteration {iteration})...",
            self.MAGENTA
        ))

    def on_healing_complete(self, fix_record: FixRecord) -> None:
        """Called when healing completes."""
        if fix_record.was_successful:
            self.log(LogLevel.INFO, self._colorize(
                f"✓ Claude Code fix applied (fix #{fix_record.iteration})",
                self.GREEN
            ))
        else:
            status_msg = {
                "timeout": "timed out",
                "failed": "failed",
            }.get(fix_record.status.value, "unknown status")
            self.log(LogLevel.ERROR, self._colorize(
                f"✗ Claude Code {status_msg}",
                self.RED
            ))

    def on_phase_change(self, phase: str) -> None:
        """Called when agent phase changes."""
        banner = f"╔══ PHASE: {phase} ══"
        self.log(LogLevel.INFO, "")
        self.log(LogLevel.INFO, self._colorize(banner, self.CYAN + self.BOLD))

    def on_summary(self, summary: dict) -> None:
        """Called to display final summary."""
        self.log(LogLevel.INFO, "")
        self.log(LogLevel.INFO, self._colorize("=" * 60, self.CYAN + self.BOLD))
        self.log(LogLevel.INFO, self._colorize("AGENT RUN SUMMARY", self.CYAN + self.BOLD))
        self.log(LogLevel.INFO, self._colorize("=" * 60, self.CYAN + self.BOLD))

        status_color = self.GREEN if summary["success"] else self.RED
        self.log(LogLevel.INFO, f"  Status:           {self._colorize(str(summary['success']).upper(), status_color)}")
        self.log(LogLevel.INFO, f"  Total iterations: {summary['total_iterations']}")
        self.log(LogLevel.INFO, f"  Fixes applied:    {summary['total_fixes']}")
        self.log(LogLevel.INFO, f"  Errors handled:   {summary['errors_count']}")

        duration = int(summary['duration_seconds'])
        minutes, seconds = divmod(duration, 60)
        self.log(LogLevel.INFO, f"  Duration:         {minutes}m {seconds}s")

        self.log(LogLevel.INFO, self._colorize("=" * 60, self.CYAN + self.BOLD))
