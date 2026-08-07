#!/usr/bin/env bash
# gful · caches Claude Code rate-limit usage for the status bar.
# Pipe the statusLine stdin JSON into this from your statusline command:
#   echo "$input" | /path/to/gful/scripts/claude-usage-sink.sh 2>/dev/null &
# Claude Code populates .rate_limits for Pro/Max accounts; every running
# session keeps the cache fresh. Writes are atomic; silent on any failure.
set -euo pipefail

CACHE_DIR="$HOME/.cache/gful-tmux"
CACHE="$CACHE_DIR/usage.json"
mkdir -p "$CACHE_DIR"

out="$(jq -c '{
  five_pct: (.rate_limits.five_hour.used_percentage // null),
  five_reset: (.rate_limits.five_hour.resets_at // null),
  week_pct: (.rate_limits.seven_day.used_percentage // null),
  week_reset: (.rate_limits.seven_day.resets_at // null)
}' 2>/dev/null)" || exit 0

# don't clobber a good cache with an empty payload (rate_limits is absent
# until the session's first API response)
[ "$(printf '%s' "$out" | jq -r '.five_pct // .week_pct // empty')" ] || exit 0

printf '%s\n' "$out" > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
