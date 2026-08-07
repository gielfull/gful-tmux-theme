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
set -g @plugin 'gielfull/tmux-gful'
```

Then `prefix + I`.

### Manual

```tmux
run ~/Code/tmux-gful/gful.tmux
```

Reload with `tmux source-file ~/.tmux.conf`.
