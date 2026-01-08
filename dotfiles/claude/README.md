# Claude Code Configuration

**Claude Code** is Anthropic's official CLI tool for AI-assisted coding.

## Files

- `settings.local.json` - Global settings, permissions, and hooks

## Features Configured

### Stop Hook (Session Logger)
When a Claude Code session ends, the `session-logger.sh` script is executed to log the session to `WORK_LOGS`.

```json
{
  "hooks": {
    "Stop": [{
      "matcher": {},
      "hooks": [{
        "type": "command",
        "command": "/home/adam-koszalka/ŻYCIE/VIBECODING/session-logger.sh",
        "timeout": 5
      }]
    }]
  }
}
```

### Global Permissions
Pre-approved commands for convenience:
- System info: `lspci`, `lsusb`, `journalctl`
- Package management: `apt install`, `dnf install`, `pacman`
- Audio/display: `wpctl`, `brightnessctl`
- Network: `nmcli device`
- File operations: `mkdir`, `cp`, `chmod`, `ls`

## Installation

```bash
mkdir -p ~/.claude
cp settings.local.json ~/.claude/
```

## Session Logger

The `session-logger.sh` script:
1. Receives JSON input from Claude Code Stop hook
2. Extracts working directory and stop reason
3. Appends entry to `~/ŻYCIE/VIBECODING/WORK_LOGS`

Format:
```
## 2025-01-08
### Sessions
- **14:30** | `project-name` | end_turn
```

## Related Files

- `/home/adam-koszalka/ŻYCIE/VIBECODING/session-logger.sh` - Hook script
- `/home/adam-koszalka/ŻYCIE/VIBECODING/WORK_LOGS` - Session log file
