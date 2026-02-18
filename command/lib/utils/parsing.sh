#!/bin/bash
# =============================================================================
# Argument Parsing Utilities
# Utility functions for parsing command line arguments
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils/usage.sh"

# Parse command line arguments
parse_args() {
    local skip_install=false
    local tags_only=""
    local dry_run=false
    local recreate_venv=false
    local skip_check=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -s|--skip-install)
                skip_install=true
                ;;
            -t|--tags-only)
                if [[ -n "${2:-}" ]] && [[ "${2:0:1}" != "-" ]]; then
                    tags_only="$2"
                    shift
                else
                    echo "Error: --tags-only requires an argument" >&2
                    exit 1
                fi
                ;;
            --dry-run)
                dry_run=true
                ;;
            --recreate-venv)
                recreate_venv=true
                ;;
            --skip-check)
                skip_check=true
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
        shift
    done

    export SKIP_INSTALL="$skip_install"
    export TAGS_ONLY="$tags_only"
    export DRY_RUN="$dry_run"
    export RECREATE_VENV="$recreate_venv"
    export SKIP_CHECK="$skip_check"
}
