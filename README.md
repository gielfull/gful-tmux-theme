# tmux-gful

A cyberpunk theme for tmux. Deep void background, electric-cyan session block
that flips hot pink while the prefix is armed, ultraviolet window tabs, and
caution-yellow messages.

## Palette

| name   | hex       | used for                          |
|--------|-----------|-----------------------------------|
| void   | `#0d0221` | status bar background             |
| grid   | `#261447` | inactive pane borders             |
| cyan   | `#05d9e8` | session block, active pane border |
| pink   | `#ff2a6d` | prefix alert, copy-mode selection |
| violet | `#d300c5` | current window, host block        |
| yellow | `#f9f002` | clock, messages, activity         |
| text   | `#9bf3ff` | foreground                        |
| dim    | `#6b6b8d` | muted foreground                  |

## Claude Code status badges

The theme ships a built-in module that shows each window's [Claude Code](https://docs.anthropic.com/en/docs/claude-code) session state right in the tab:

The badge is Claude's spark (`✻` by default); its color carries the state:

| badge | state | meaning |
|-------|-------|---------|
| `✻` orange | working | Claude is processing a prompt or running tools |
| `✻` pink | needs you | permission prompt or waiting for input (shows unattended minutes after 1m, e.g. `✻3m`; the timer resets while the window is focused) |
| `✻` cyan | done | turn finished |
| `✻` dim | idle | session open, nothing running |

With Nerd Fonts ≥ v3.4 you can use the real Claude logo glyph (`cod-claude`, `U+EC82`) instead:

```tmux
set -g @gful_claude_icon ""
```

**How it works:** Claude Code hooks call `scripts/claude-status-hook.sh` on session events, which stamps window-scoped tmux user options (`@gful_claude_state` etc.). The tab format renders them via `scripts/claude-badge.sh`, which also clears stale state whenever the `claude` process is gone from the pane's tty — so there's no background daemon and badges never outlive a killed session.

**Enable it** (one-time, after installing the theme):

```sh
~/.tmux/plugins/gful-tmux-theme/scripts/install-claude-hooks.sh
```

This merges six hook entries into `~/.claude/settings.json` (idempotent; existing hooks are preserved; all entries are `async` so they add no latency). Restart Claude Code sessions to activate. Badges update within `status-interval` (5s). If several Claude sessions share one window, the most recent event wins.

## Requirements

- tmux ≥ 3.2 (truecolor styles); developed on 3.7
- A [Nerd Font](https://www.nerdfonts.com/) for the rounded separators (``/``)
- Truecolor terminal. If colors look off, add:

  ```tmux
  set -g default-terminal "tmux-256color"
  set -ga terminal-overrides ",*:Tc"
  ```

## Install

### TPM

```tmux
set -g @plugin 'gielfull/gful-tmux-theme'
```

Then `prefix + I`.

### Manual

```tmux
run ~/Code/tmux-gful/gful.tmux
```

Reload with `tmux source-file ~/.tmux.conf`.
