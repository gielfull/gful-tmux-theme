#!/usr/bin/env bash
# gful · installs the Claude Code status hooks into ~/.claude/settings.json.
# Idempotent: re-running replaces previous gful hook entries (e.g. after the
# plugin moves). Other hooks in the file are left untouched.
set -euo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude-status-hook.sh"
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"

python3 - "$HOOK" "$SETTINGS" <<'PY'
import json, os, sys

hook, path = sys.argv[1], sys.argv[2]
events = {
    "SessionStart": "start",
    "UserPromptSubmit": "work",
    "PreToolUse": "work",
    "Notification": "input",
    "Stop": "done",
    "SessionEnd": "end",
}

data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)

hooks = data.setdefault("hooks", {})
for event, arg in events.items():
    entries = hooks.setdefault(event, [])
    for e in entries:
        e["hooks"] = [h for h in e.get("hooks", [])
                      if "claude-status-hook.sh" not in h.get("command", "")]
    entries[:] = [e for e in entries if e.get("hooks")]
    entries.append({"hooks": [{"type": "command",
                               "command": f"{hook} {arg}",
                               "async": True}]})

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"gful: Claude Code status hooks installed into {path}")
print("Restart Claude Code sessions (or run /hooks once) to activate.")
PY
