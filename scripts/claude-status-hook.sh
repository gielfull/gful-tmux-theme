#!/usr/bin/env bash
# gful · Claude Code event hook.
# Wired into Claude Code's hooks (~/.claude/settings.json) — receives an event
# keyword and stamps window-scoped tmux user options that the tab badge reads:
#   @gful_claude_state  idle | working | input | done
#   @gful_claude_pane   pane running claude (for liveness checks)
#   @gful_claude_since  epoch of the last state change
# Outside tmux this is a silent no-op.

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

case "$1" in
  start) state="idle" ;;
  work)  state="working" ;;
  input) state="input" ;;
  done)  state="done" ;;
  end)   state="" ;;
  *)     exit 0 ;;
esac

if [ -z "$state" ]; then
  tmux set -w -t "$TMUX_PANE" -u @gful_claude_state \; \
       set -w -t "$TMUX_PANE" -u @gful_claude_pane \; \
       set -w -t "$TMUX_PANE" -u @gful_claude_since 2>/dev/null
else
  tmux set -w -t "$TMUX_PANE" @gful_claude_state "$state" \; \
       set -w -t "$TMUX_PANE" @gful_claude_pane "$TMUX_PANE" \; \
       set -w -t "$TMUX_PANE" @gful_claude_since "$(date +%s)" 2>/dev/null
fi
exit 0
