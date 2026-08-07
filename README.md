# tmux-gful

A cyberpunk theme for tmux with built-in [Claude Code](https://docs.anthropic.com/en/docs/claude-code) integration. Deep void background, electric-cyan session block, ultraviolet tabs — and your Claude sessions reporting their state and usage right in the status line.

**What you get:**

- **Theme** — cyberpunk status bar, tabs, pane borders, copy-mode and message styling
- **Prefix indicator** — the session block flips hot pink while the prefix key is armed
- **Directory tabs** — windows auto-name themselves after the pane's current directory
- **Claude status badges** — each tab shows its Claude Code session state (working / needs you / done / idle), with an unattended-wait timer
- **Claude usage meter** — status-right shows your rate-limit windows (`5h`, `week`, optional per-model), color-ramped by pressure

```
 ⌁ session   1 ▸ ✻ api   2 ▸ web        ✻ 5h 37% ▸ week 82% ▸ 23:18 ▸ 06-Aug  host
```

## Install

### TPM

```tmux
set -g @plugin 'gielfull/gful-tmux-theme'
```

Then `prefix + I`. The theme applies immediately; the two Claude modules below each need one extra opt-in step.

### Manual

```tmux
run /path/to/gful-tmux-theme/gful.tmux
```

Reload with `tmux source-file ~/.tmux.conf`.

### Requirements

- tmux ≥ 3.2 (truecolor styles); developed on 3.7
- A [Nerd Font](https://www.nerdfonts.com/) for the rounded separators (``/``)
- Truecolor terminal. If colors look off, add:

  ```tmux
  set -g default-terminal "tmux-256color"
  set -ga terminal-overrides ",*:Tc"
  ```

- Claude modules: `jq`, and a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) Pro/Max login for the usage meter

## Palette

| name   | hex       | used for                          |
|--------|-----------|-----------------------------------|
| void   | `#0d0221` | status bar background             |
| grid   | `#261447` | inactive pane borders             |
| cyan   | `#05d9e8` | session block, active pane border |
| pink   | `#ff2a6d` | prefix alert, copy-mode selection |
| violet | `#d300c5` | current window, host block        |
| yellow | `#f9f002` | clock, messages, activity         |
| claude | `#D97757` | Claude badge/meter accents        |
| text   | `#9bf3ff` | foreground                        |
| dim    | `#6b6b8d` | muted foreground                  |

All styles live in `gful.tmux.conf`; tweak freely.

## Module: Claude status badges

Every window running a Claude Code session gets a spark badge (`✻`) in its tab; the color carries the state:

| badge | state | meaning |
|-------|-------|---------|
| `✻` orange | working | Claude is processing a prompt or running tools |
| `✻` pink | needs you | permission prompt or waiting for input; shows unattended minutes after 1m (e.g. `✻3m`) — the timer resets while the window is focused |
| `✻` cyan | done | turn finished, ball in your court |
| `✻` dim | idle | session open, nothing running |

**Enable it** (one-time, after installing the theme):

```sh
~/.tmux/plugins/gful-tmux-theme/scripts/install-claude-hooks.sh
```

This merges six hook entries into `~/.claude/settings.json` (idempotent; existing hooks preserved; all `async`, so no added latency). Already-running Claude sessions pick the hooks up after a restart or one visit to `/hooks`.

**How it works:** Claude Code hooks call `scripts/claude-status-hook.sh` on session events, which stamps window-scoped tmux user options. The tab format renders them via `scripts/claude-badge.sh`, which doubles as the janitor: when the `claude` process is gone from the tracked pane's tty, stale state is cleared — no background daemon, badges never outlive a killed session. Badges update within `status-interval` (5s). If several Claude sessions share one window, the most recent event wins.

**The real Claude logo:** with Nerd Fonts ≥ v3.4 you can swap the spark for the actual logo glyph (`cod-claude`, `U+EC82`):

```tmux
set -g @gful_claude_icon ""
```

## Module: Claude usage meter

Status-right can show your Claude rate-limit windows, color-ramped by pressure (cyan → yellow ≥50% → pink ≥80%):

```
✻ 5h 37% ▸ week 82% ▸ fable 41% ▸ 23:18 ▸ 06-Aug  host
```

Claude Code exposes these numbers (Pro/Max accounts) only through the statusLine payload, so the theme uses a sink. Add one line to your statusline script (the command configured as `statusLine` in `~/.claude/settings.json`), right after it reads stdin into `$input`:

```sh
echo "$input" | ~/.tmux/plugins/gful-tmux-theme/scripts/claude-usage-sink.sh 2>/dev/null &
```

Every running Claude session then keeps `~/.cache/gful-tmux/usage.json` fresh, and `scripts/claude-usage.sh` renders it. No credentials are read and no API is polled. The segment hides itself when the cache is missing or older than an hour (e.g. machines without Claude Code), and the numbers freeze between sessions — they only move while some Claude session is alive to refresh them.

**Optional model-scoped window.** The renderer appends a third meter if `~/.cache/gful-tmux/model.json` exists and is fresh (<1h):

```json
{"label":"fable","pct":41.7}
```

The theme doesn't populate this file — model-scoped limits (e.g. a weekly Fable/Opus window) aren't in the statusLine payload, only in the OAuth usage endpoint that `/usage` reads. If you already have a script fetching that (a statusline widget, a cron job), have it tee the used-percentage into this file and the bar picks it up with the same color ramp.

## Options

| option | default | meaning |
|--------|---------|---------|
| `@gful_claude_icon` | `✻` | glyph used by the tab badge and set once, globally (`set -g`) |

Cache files live in `~/.cache/gful-tmux/` (`usage.json`, `model.json`); state travels through window-scoped tmux user options (`@gful_claude_state`, `@gful_claude_pane`, `@gful_claude_since`).

## Repo layout

```
gful.tmux                        TPM entry point
gful.tmux.conf                   all theme styles
scripts/claude-status-hook.sh    Claude Code event hook → tmux options
scripts/claude-badge.sh          tab badge renderer + stale-state janitor
scripts/install-claude-hooks.sh  one-shot settings.json hook installer
scripts/claude-usage-sink.sh     statusLine JSON → usage cache
scripts/claude-usage.sh          status-right usage meter renderer
```
