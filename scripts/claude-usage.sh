#!/usr/bin/env bash
# gful · renders Claude Code usage (5h + weekly windows) for status-right.
# Reads the cache maintained by claude-usage-sink.sh; prints nothing when the
# cache is missing or stale (>1h), so the bar stays clean on machines that
# don't run Claude Code.
#
# Optional extra segment: if ~/.cache/gful-tmux/model.json exists and is fresh,
# it is appended as a model-scoped window, e.g. {"label":"fable","pct":37.4}.
# Anything may maintain that file (see README).
CACHE_DIR="$HOME/.cache/gful-tmux"
CACHE="$CACHE_DIR/usage.json"
MODEL_CACHE="$CACHE_DIR/model.json"

now=$(date +%s)
mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0; }
fresh() { [ -f "$1" ] && [ $(( now - $(mtime "$1") )) -lt 3600 ]; }

# usage color ramp: calm cyan → caution yellow → hot pink
tint() {
  awk -v p="$1" 'BEGIN {
    if (p >= 80)      print "#ff2a6d";
    else if (p >= 50) print "#f9f002";
    else              print "#05d9e8";
  }'
}

seg=""
append() { # label, pct
  p=$(printf '%.0f' "$2")
  [ -n "$seg" ] && seg="$seg #[fg=#6b6b8d]▸ "
  seg="$seg#[fg=$(tint "$p")]$1 ${p}%"
}

if fresh "$CACHE"; then
  five="$(jq -r '.five_pct // empty' "$CACHE" 2>/dev/null)"
  week="$(jq -r '.week_pct // empty' "$CACHE" 2>/dev/null)"
  [ -n "$five" ] && append "5h" "$five"
  [ -n "$week" ] && append "week" "$week"
fi

if fresh "$MODEL_CACHE"; then
  mlabel="$(jq -r '.label // "model"' "$MODEL_CACHE" 2>/dev/null)"
  mpct="$(jq -r '.pct // empty' "$MODEL_CACHE" 2>/dev/null)"
  [ -n "$mpct" ] && append "$mlabel" "$mpct"
fi

[ -n "$seg" ] || exit 0
printf '#[fg=#D97757]✻ %s #[fg=#6b6b8d]▸#[default] ' "$seg"
