#!/usr/bin/env bash
# Humanitic Plugin Installer
# Links meta-agentic-loop skills to Claude Code commands

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$PROJECT_ROOT/.claude/commands"
SKILLS_DIR="$SCRIPT_DIR/.claude/skills"

# User-invocable skills (not internal-only)
SKILLS=(
  "start"
  "cockpit"
  "shift"
  "research"
  "contribute"
  "curiosity"
  "governance"
  "audit"
  "cei"
  "voice"
  "campaign"
)

echo "Installing humanitic plugin commands..."

mkdir -p "$COMMANDS_DIR"

for skill in "${SKILLS[@]}"; do
  src="../../plugin/.claude/skills/${skill}.md"
  dest="$COMMANDS_DIR/${skill}.md"

  if [ -L "$dest" ]; then
    rm "$dest"
  fi

  ln -sf "$src" "$dest"
  echo "  /${skill}"
done

echo ""
echo "Installed ${#SKILLS[@]} commands to .claude/commands/"
echo "Run /help to see available commands."
