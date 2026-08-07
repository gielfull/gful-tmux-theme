#!/usr/bin/env bash
# gful · renders the Claude Code badge for one window.
# Called from window-status-format via #(); prints nothing when no Claude
# session is tracked. Doubles as the janitor: when the claude process is gone
# from the tracked pane's tty, the stale state is cleared — no daemon needed.
win="$1"

state="$(tmux show -wqv -t "$win" @gful_claude_state 2>/dev/null)"
[ -n "$state" ] || exit 0

clear_state() {
  tmux set -w -t "$win" -u @gful_claude_state \; \
       set -w -t "$win" -u @gful_claude_pane \; \
       set -w -t "$win" -u @gful_claude_since 2>/dev/null
}

pane="$(tmux show -wqv -t "$win" @gful_claude_pane 2>/dev/null)"
tty="$(tmux display -p -t "$pane" '#{pane_tty}' 2>/dev/null)"
if [ -z "$tty" ] || ! ps -o comm= -t "${tty#/dev/}" 2>/dev/null | grep -q claude; then
  clear_state
  exit 0
fi

# "needs you" badge ages: show minutes once it has waited over a minute.
# While the window is focused (active in an attached session) the user is
# already looking at it, so the timer resets — it only accrues unattended.
elapsed=""
if [ "$state" = "input" ]; then
  now="$(date +%s)"
  focus="$(tmux display -p -t "$win" '#{window_active} #{session_attached}' 2>/dev/null)"
  if [ "${focus%% *}" = "1" ] && [ "${focus##* }" -ge 1 ] 2>/dev/null; then
    tmux set -w -t "$win" @gful_claude_since "$now" 2>/dev/null
  else
    since="$(tmux show -wqv -t "$win" @gful_claude_since 2>/dev/null)"
    if [ -n "$since" ] && [ $((now - since)) -ge 60 ]; then
      elapsed="$(((now - since) / 60))m"
    fi
  fi
fi

# badge glyph: Claude's spark ✻ by default. Set @gful_claude_icon to override,
# e.g. the real Claude logo (Nerd Font cod-claude U+EC82, needs NF >= 3.4):
#   set -g @gful_claude_icon ""   <- put the literal glyph in your conf
# Color carries the state.
icon="$(tmux show -gqv @gful_claude_icon 2>/dev/null)"
[ -n "$icon" ] || icon="✻"

case "$state" in
  working) printf '#[fg=#D97757,bold]%s#[nobold] ' "$icon" ;;
  input)   printf '#[fg=#ff2a6d,bold]%s%s#[nobold] ' "$icon" "$elapsed" ;;
  done)    printf '#[fg=#05d9e8]%s ' "$icon" ;;
  idle)    printf '#[fg=#6b6b8d]%s ' "$icon" ;;
esac
