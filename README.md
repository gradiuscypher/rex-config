# rex-config

My personal [Rex](https://www.superlogical.com/rex/docs) configuration: tmux-style
`Ctrl+A` sequences, Vim-style pane navigation, repeatable resizing, and a
Neovim config editor. [`init.lua`](init.lua) adds bindings without removing
Rex's defaults; `Ctrl+A` itself becomes a sequence prefix.

This repository contains configuration and documentation, not runtime state,
credentials, agent settings, or a copy of Rex's generated agent skill.

## Prerequisites

- Install Rex using the [official installation documentation](https://www.superlogical.com/rex/docs/installation.md),
  with `rex` available on your `PATH`.
- Install `nvim` on the machine running the terminal only if you want the
  `Ctrl+A M` config-edit binding. The other bindings do not require it.

Validated with `rex 0.1.0-preview.15` using `rex config check ./init.lua`.
File validation checks the Lua declarations, not the availability of every
client action or of `nvim`.

## Install the configuration

Review `init.lua` before running it: a Rex config is executable Lua. From this
repository's root, run the following in a POSIX shell on the **Rex server's
machine**. It validates the candidate before copying, saves an existing config
to a uniquely named adjacent backup, and reloads only after a successful copy.
It replaces the active config rather than merging it.

```sh
(
  set -eu
  rex config check ./init.lua
  target="${REX_CONFIG-${XDG_CONFIG_HOME-$HOME/.config}/rex/init.lua}"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup="$(mktemp "${target}.backup.XXXXXXXX")"
    cp -p "$target" "$backup"
    printf 'Saved existing config: %s\n' "$backup"
  fi
  cp ./init.lua "$target"
  rex config reload
)
```

The destination follows Rex's [configuration lookup](https://www.superlogical.com/rex/docs/customize/config.md):
`REX_CONFIG`, otherwise `$XDG_CONFIG_HOME/rex/init.lua`, otherwise
`$HOME/.config/rex/init.lua`. If you use either override, use a nonempty path
and ensure this shell matches the server's environment. In particular,
exporting `REX_CONFIG` in a terminal does **not** change an already-running
server's config path; it must be set on the server process.

Configuration is read and stored **server-side**, not synchronized between
hosts. Install it separately on each server where you want these bindings,
and run `rex config reload` locally there; remote reload requests are refused.
Rex does not automatically watch the file for changes. After edits, run
`rex config check` before reloading. `rex keymap` can diagnose bindings against
the running server and client, which file-only validation cannot fully check.
To restore a backup, copy the printed backup path over the active config,
validate it, and reload.

## Shortcuts

Press **Ctrl+A, release, then press the listed key**. Uppercase letters mean
Shift plus the letter. Escape cancels an incomplete
[key sequence](https://www.superlogical.com/rex/docs/customize/key-sequences.md).

| After Ctrl+A | Action |
| --- | --- |
| `Ctrl+A` | Send one literal Ctrl+A to the terminal or nested tmux |
| Shift+backslash (`\|` on a US layout) / `-` | Split right / below |
| `h` / `j` / `k` / `l`, or arrow keys | Focus left / down / up / right |
| `o` | Focus the next pane |
| `Alt+h` / `Alt+j` / `Alt+k` / `Alt+l` | Resize left / down / up / right; enter repeat mode |
| `z` | Toggle pane zoom |
| `!` | Move the pane into a new tab |
| `x` | **Close the focused pane directly, without tmux's confirmation prompt** |
| `c` | Create a tab |
| `n` / `p`, or `Ctrl+N` / `Ctrl+P` | Next / previous tab |
| `,` | Rename the tab |
| `0`–`9` | Select the first through tenth tabs (Rex indices 1–10) |
| `s` / `$` | Switch / rename the session |
| `[` | Enter scroll mode |
| `r` / `R` | Reload configuration |
| `M` | Open the active config in a right-hand `nvim` split |

**Ctrl+A x is destructive:** save work before using it.

- **Resize mode:** after the first prefix-plus-Alt-direction shortcut, repeat
  `Alt+h/j/k/l` without the prefix. Each step moves the divider by 5 percent,
  not tmux's 5 cells. Escape exits. This mode is nonexclusive: other keys keep
  their ordinary behavior and can reach the terminal while resizing remains active.
- **Scroll mode:** Page Up / Page Down scroll; `q` or Escape exits. This mode
  is exclusive, so other keys are ignored.
- `Ctrl+A a` is intentionally unbound; there is no built-in Rex last-tab action
  used by this config.

See the official [key-mode semantics](https://www.superlogical.com/rex/docs/customize/key-modes.md).

## Give agents current Rex guidance

Use Rex's [built-in agent setup](https://www.superlogical.com/rex/docs/automate/agent-skill.md),
not a copied guide that will go stale. The default is **account-wide** and
covers all detected supported agents:

```sh
rex skill setup --dry-run
rex skill setup
rex skill status
```

Supported setup targets in this version are Claude Code (`claude`), Codex
(`codex`), OpenCode (`opencode`), and Pi (`pi`). Detection uses their config
directories or programs on `PATH`; it is not a promise to support every agent.
If none is detected, setup installs the shared skill under `~/.agents/skills`.
To cover supported agents even when they are absent or undetected, explicitly
select them; `--agent` is repeatable:

```sh
rex skill setup --agent claude --agent codex --agent opencode --agent pi --dry-run
rex skill setup --agent claude --agent codex --agent opencode --agent pi
rex skill status --json
```

Select only the targets you want. Setup is safe to rerun when adding agents:
it updates Rex-managed files while preserving unrelated settings. A foreign
skill named `rex` is left alone; inspect conflicts rather than adding `--force`
blindly. Omit `--project` for account-wide installation. New installs leave
automatic session naming off; rerunning setup retains an existing choice.

Start a **new agent session inside Rex** after setup. Approve the Rex hook
through `/hooks` in Codex; Claude Code requires trusting the working folder
before hooks run. OpenCode and Pi receive the skill but no startup hook.
The installed skill reads its version-matched guide from the installed CLI,
so upgrading Rex updates the guidance without copying it into this repo.
Other command-capable agents can run `rex skill show` and follow its output.

For repository-specific agent instructions, start with [`AGENTS.md`](AGENTS.md);
[`docs/rex.md`](docs/rex.md) explains Rex's model, targeting, and automation safety.
