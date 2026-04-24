#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.claude/agents"

install -m 644 "$SRC_DIR/claude/agents/tech-researcher.md" "$HOME/.claude/agents/tech-researcher.md"
install -m 644 "$SRC_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo "[dotfiles] Claude Code personal assets installed to ~/.claude/"
