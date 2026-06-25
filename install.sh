#!/usr/bin/env bash
# Entry point for devpod dotfiles support.
# devpod looks for install.sh at the repository root and runs it when
# bootstrapping a workspace with this dotfiles repository.
# https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace
#
# All logic lives in scripts/bootstrap.sh; this file is just a redirect.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/scripts/bootstrap.sh" "$@"
