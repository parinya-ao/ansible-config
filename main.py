#!/usr/bin/env python3
# SPDX-License-Identifier: MIT-0
# =============================================================================
# Fully Autonomous Ansible Molecule Testing Agent
# =============================================================================
# DDD Lite + Hexagonal Architecture Implementation
#
# Layers:
#   - Domain: Core business logic (models, exceptions)
#   - Application: Use cases + Ports (interfaces)
#   - Infrastructure: Adapters (Molecule, Claude, Console)
#   - Interfaces: CLI entry point
#
# Usage:
#   python main.py                    # Full autonomous run
#   python main.py --scenario ci      # Run specific scenario
#   python main.py --skip-final       # Skip final clean-room validation
# =============================================================================

import argparse
import json
import sys
from pathlib import Path

# Import from clean architecture layers
from src.domain import AgentConfig
from src.application import AutonomousAgentUseCase
from src.infrastructure import (
    MoleculeExecutorAdapter,
    ClaudeHealerAdapter,
    ConsoleObserverAdapter,
    Settings,
)


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Fully Autonomous Ansible Molecule Testing Agent",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python main.py                      # Run with defaults
  python main.py --scenario ci        # Test CI scenario
  python main.py --max-retries 20     # More retries for complex issues
  python main.py --skip-final         # Skip clean-room validation
  python main.py --verbose            # Enable verbose logging
        """
    )

    parser.add_argument(
        "--scenario", "-s",
        default=AgentConfig.DEFAULT_SCENARIO,
        help=f"Molecule scenario to test (default: {AgentConfig.DEFAULT_SCENARIO})"
    )

    parser.add_argument(
        "--max-retries", "-r",
        type=int,
        default=AgentConfig.DEFAULT_MAX_RETRIES,
        help=f"Maximum retry attempts (default: {AgentConfig.DEFAULT_MAX_RETRIES})"
    )

    parser.add_argument(
        "--skip-final",
        action="store_true",
        help="Skip final clean-room validation"
    )

    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose logging"
    )

    parser.add_argument(
        "--project-root",
        type=Path,
        default=None,
        help="Project root directory (default: current directory)"
    )

    return parser.parse_args()


def create_adapters(config: AgentConfig):
    """Create infrastructure adapters.

    This is where we wire up the concrete implementations.

    Args:
        config: Agent configuration

    Returns:
        Tuple of (executor, healer, observer) adapters
    """
    # Setup environment
    env = Settings.get_ansible_env()
    Settings.set_project_root(config.project_root)

    # Create executor adapter
    executor = MoleculeExecutorAdapter(
        scenario=config.scenario,
        env=env,
        project_root=config.project_root,
    )

    # Create healer adapter
    healer = ClaudeHealerAdapter(
        project_root=config.project_root,
    )

    # Create observer adapter
    observer = ConsoleObserverAdapter(verbose=config.verbose)

    return executor, healer, observer


def save_summary(summary: dict, project_root: Path):
    """Save agent run summary to file.

    Args:
        summary: Summary dictionary
        project_root: Project root directory
    """
    summary_file = project_root / ".agent-summary.json"
    with open(summary_file, "w") as f:
        json.dump(summary, f, indent=2)
    print(f"\nSummary saved to: {summary_file}")


def main():
    """Main entry point."""
    args = parse_args()

    # Determine project root
    project_root = args.project_root or Path.cwd()

    # Create configuration
    config = AgentConfig.create(
        scenario=args.scenario,
        max_retries=args.max_retries,
        skip_final=args.skip_final,
        project_root=project_root,
        verbose=args.verbose,
    )

    # Create adapters
    executor, healer, observer = create_adapters(config)

    # Create and run use case
    use_case = AutonomousAgentUseCase(
        config=config,
        executor=executor,
        healer=healer,
        observer=observer,
    )

    try:
        success = use_case.run()

        # Save summary
        summary = use_case.state.get_summary()
        save_summary(summary, project_root)

        sys.exit(0 if success else 1)

    except KeyboardInterrupt:
        observer.log(
            LogLevel.INFO,
            "Agent stopped by user"
        )
        sys.exit(130)
    except Exception as e:
        observer.log(
            LogLevel.CRITICAL,
            f"Unexpected error: {e}"
        )
        sys.exit(1)


if __name__ == "__main__":
    # Import LogLevel for main
    from src.application.ports import LogLevel
    main()
