#!/usr/bin/env bash
# gful — cyberpunk tmux theme. TPM entry point.
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux source-file "$CURRENT_DIR/gful.tmux.conf"
