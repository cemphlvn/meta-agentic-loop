# Integration Reality — Claude Code Hooks

> What works, what doesn't, and why the user IS the loop

---

## Summary

Claude Code hooks are **passive**. They can inject context and block tools, but they **cannot invoke Claude**. The "eternal forward loop" is philosophically correct but technically requires user participation.

---

## What Hooks CAN Do

### SessionStart

```json
{
  "SessionStart": [{
    "matcher": "*",
    "hooks": [{
      "type": "command",
      "command": "bash scripts/hooks/load-context.sh"
    }]
  }]
}
```

- **stdout** → Injected into Claude's context ✅
- **$CLAUDE_ENV_FILE** → Persist environment vars ✅
- Runs on session start, before first user message

### PreToolUse

```json
{
  "PreToolUse": [{
    "matcher": "Write|Edit",
    "hooks": [{
      "type": "command",
      "command": "python3 scripts/hooks/governance-lock.py"
    }]
  }]
}
```

- **stdin** ← JSON with `{tool_name, tool_input, session_id, ...}`
- **exit 0** → Allow the tool call
- **exit 2** → Block with reason on stderr
- Cannot invoke Claude actions

### Stop

- Runs on session end
- Can verify, log, cleanup
- Cannot continue the session

---

## What Hooks CANNOT Do

```
❌ Invoke Claude to perform actions
❌ Trigger slash commands programmatically
❌ Run agentic loops automatically
❌ Send messages to the conversation
❌ Call other tools
```

---

## The Correct Mental Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    REALITY OF CLAUDE CODE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User types → Claude responds → User continues                   │
│       ↑                              │                           │
│       └──────────────────────────────┘                           │
│                                                                  │
│  Hooks: Can inject context, block tools, set env                 │
│  Hooks: CANNOT invoke Claude, CANNOT auto-loop                   │
│                                                                  │
│  Skills: User-invocable with /skill-name                         │
│  Skills: Define behavior Claude follows when invoked             │
│                                                                  │
│  The loop continues THROUGH the user, not around them.           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Hook Input Format

All hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.txt",
  "cwd": "/current/working/dir",
  "permission_mode": "ask|allow",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file",
    "content": "..."
  }
}
```

---

## Example: Blocking Governance Writes

```python
#!/usr/bin/env python3
import json
import sys

# Read hook input
input_data = json.load(sys.stdin)
file_path = input_data.get("tool_input", {}).get("file_path", "")

# Check if governance file
if ".claude/governance/" in file_path:
    print("Governance files are USER-ONLY", file=sys.stderr)
    sys.exit(2)  # Block

sys.exit(0)  # Allow
```

---

## Settings.json Template

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "bash ${PROJECT_ROOT}/scripts/hooks/load-context.sh",
        "timeout": 10
      }]
    }],
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "python3 ${PROJECT_ROOT}/scripts/hooks/governance-lock.py",
        "timeout": 5
      }]
    }]
  }
}
```

**Note**: Use `${PROJECT_ROOT}` or relative paths from the project directory, not from the plugin.

---

## Common Mistakes

### 1. Wrong Script Paths

❌ Wrong:
```json
"command": "python3 scripts/hooks/governance-lock.py"
```

✅ Correct (if file is in plugin/):
```json
"command": "python3 plugin/scripts/hooks/governance-lock.py"
```

### 2. Expecting Auto-Loop

❌ Wrong assumption:
```
"The loop will continue automatically after SessionStart"
```

✅ Reality:
```
SessionStart injects context. Then Claude waits for user input.
```

### 3. Trying to Invoke Claude from Scripts

❌ This doesn't work:
```bash
# Cannot invoke Claude from a script
echo "/loop continue"  # This is just text, not a command
```

✅ Correct approach:
```bash
# Output recommendations, user executes them
echo "RECOMMENDED: Run /loop continue"
```

---

## Diagnostic Tools

### loop-runner.sh

A diagnostic script that shows loop state and recommendations:

```bash
./scripts/loop-runner.sh            # Show state + recommendations
./scripts/loop-runner.sh --status   # Current state only
```

This outputs what SHOULD happen next. The user then types the command.

---

## Philosophy Alignment

The user being part of the loop is philosophically correct:

> "Muhtaç olduğun kudret, damarlarındaki asil kanda mevcuttur."
> The power you need exists in the noble blood in your veins.

The system doesn't bypass human agency. It augments it.

> "逆水行舟，不进则退"
> Like rowing upstream: no advance is to drop back.

YOU row. The system provides the boat and the direction.

---

## Sources

- [Claude Code Hooks Documentation](https://github.com/anthropics/claude-code)
- Context7 `/anthropics/claude-code` library
- Shape shift logged: 2026-02-07 INTEGRATION-001
