#!/usr/bin/env python3
"""
Governance Lock Hook

Blocks agent modifications to governance files.
These files are USER-ONLY and immutable by agents.

Enforcement Pattern (Feb 6 2026):
- PreToolUse hook intercepts Write/Edit/MultiEdit
- Checks if target is in governance directory
- Exits with code 1 to BLOCK the operation
- Logs attempt to audit trail

Sources:
- https://code.claude.com/docs/en/security
- https://code.claude.com/docs/en/permissions
"""

import os
import sys
import json
from datetime import datetime, timezone

# Governance directory (relative to project root)
GOVERNANCE_DIR = ".claude/governance"

# Audit log location
AUDIT_LOG = ".claude/governance/.audit-log"

# Files that are LOCKED (agent-immutable)
LOCKED_FILES = [
    "GOVERNANCE.md",
    "meta-principles.md",
    "curiosity-of-curiosity.md",
    "policies.md",
    "ethics.md",
]

def get_project_root():
    """Get project root from environment or cwd."""
    return os.environ.get("PROJECT_ROOT", os.getcwd())

def is_governance_file(file_path: str) -> bool:
    """Check if file is in governance directory."""
    project_root = get_project_root()
    governance_path = os.path.join(project_root, GOVERNANCE_DIR)

    # Normalize paths
    file_path = os.path.normpath(os.path.abspath(file_path))
    governance_path = os.path.normpath(os.path.abspath(governance_path))

    # Check if file is within governance directory
    return file_path.startswith(governance_path)

def log_attempt(file_path: str, operation: str, status: str):
    """Log access attempt to audit trail."""
    project_root = get_project_root()
    audit_path = os.path.join(project_root, AUDIT_LOG)

    # Ensure directory exists
    os.makedirs(os.path.dirname(audit_path), exist_ok=True)

    timestamp = datetime.now(timezone.utc).isoformat()
    agent_id = os.environ.get("CLAUDE_AGENT_ID", "unknown")

    log_entry = f"{timestamp} | {operation:6} | {os.path.basename(file_path):30} | {agent_id:20} | {status}\n"

    try:
        with open(audit_path, "a") as f:
            f.write(log_entry)
    except Exception:
        pass  # Don't fail on logging errors

def main():
    """
    Main hook logic.

    Reads tool input from environment or stdin.
    Checks if operation targets governance files.
    Exits 0 to allow, 1 to block.
    """
    # Get file path from environment (set by Claude Code)
    file_path = os.environ.get("TOOL_INPUT_FILE_PATH", "")

    # Also check for alternate env var names
    if not file_path:
        file_path = os.environ.get("file_path", "")

    # Try to read from stdin if not in env
    if not file_path:
        try:
            input_data = sys.stdin.read()
            if input_data:
                data = json.loads(input_data)
                file_path = data.get("file_path", "")
        except Exception:
            pass

    if not file_path:
        # No file path found, allow operation (not a file operation)
        sys.exit(0)

    # Check if this is a governance file
    if is_governance_file(file_path):
        # Log the blocked attempt
        log_attempt(file_path, "WRITE", "BLOCKED")

        # Print warning message
        print(f"""
╔═══════════════════════════════════════════════════════════════════════════╗
║  ❌ BLOCKED: Governance File Modification Attempt                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  File: {os.path.basename(file_path):<66} ║
║                                                                            ║
║  Governance files are USER-ONLY and cannot be modified by agents.         ║
║                                                                            ║
║  To modify governance:                                                     ║
║    1. User must edit directly: vim {file_path:<40} ║
║    2. Or use: /governance edit <filename>                                  ║
║                                                                            ║
║  To propose changes:                                                       ║
║    /governance request <filename> "proposal" "rationale"                   ║
║                                                                            ║
║  Sources:                                                                  ║
║    - https://code.claude.com/docs/en/security                             ║
║    - https://code.claude.com/docs/en/permissions                          ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
""", file=sys.stderr)

        # Exit with code 1 to BLOCK the operation
        sys.exit(1)

    # Not a governance file, allow operation
    sys.exit(0)

if __name__ == "__main__":
    main()
