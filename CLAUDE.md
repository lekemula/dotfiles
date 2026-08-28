# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

  Personal dotfiles repository for macOS. Config files are symlinked from `~/dotfiles` to their expected locations via `install.sh`. The `PERSONAL_DOTFILES_DIRECTORY_NAME` env var controls the source directory name. Ensure that any changes to tool configurations are added in this repo and symlinked properly to maintain consistency across machines.

## Key Commands

- **Install**: `PERSONAL_DOTFILES_DIRECTORY_NAME=dotfiles ./install.sh`
- **Update all dependencies**: `./update.zsh` (or alias `upd`)
- **Reload shell**: `omz reload` (or alias `res`)

## Architecture

### Symlink-Based Setup
`install.sh` creates symlinks from this repo to home/config directories. When adding a new config file, add its symlink to `install.sh`. Executable scripts in `bin/` get symlinked to `/usr/local/bin/`.

### Shell Loading Order
0. `.zshenv` — read by *every* zsh, including non-interactive (`zsh -c`) and
   scripts. Only holds the mise shims PATH prepend, so agent tooling and scripts
   get the project's Ruby/Node instead of macOS system Ruby 2.6. Keep it fast,
   side-effect free, and idempotent — interactive setup belongs in `.zshrc`.
0b. `.zprofile` — login shells only, after `/etc/zprofile`. Sets up Homebrew and
   Docker Desktop, then re-sources `.zshenv`, because `/etc/zprofile`'s
   `path_helper` hoists `/usr/bin` back above the mise prepend.
1. `.zshrc` — entrypoint, sets `$DF_HOME`. Interactive shells only.
2. `environment.zsh` — env vars
3. `macos.zsh` — macOS-only: auto-installs tools via Homebrew if missing
4. Antigen plugins via `.antigenrc`
5. `custom.zsh` — post-plugin customizations
6. `~/.zshrc.secrets` — private env vars (not in repo, see `.zshrc.secrets.example`)

### Key Directories
- `nvim/` — Neovim config (init.lua + lua modules), symlinked to `~/.config/nvim/`
- `vim/` — Legacy Vim configs and snippets
- `claude/` — Claude Code skills, symlinked to `~/.claude/skills/`
- `claude/plugins/` — Custom Claude Code plugins (e.g., solargraph)
- `bin/` — Custom scripts symlinked to `/usr/local/bin/`

### Claude Code Config
- `claude.json` → `~/.claude/settings.json` (global Claude Code settings).
  **Gitignored — machine-local.** Claude Code writes an `autoMode` block here
  describing the environment (internal hosts, prod namespace patterns, paths to
  credential files), and this repo is public, so the live file must never be
  committed. `claude.example.json` is the tracked baseline; `install.sh` seeds
  `claude.json` from it on a fresh machine before symlinking. When changing
  settings that *should* be shared across machines, edit both files.
- `CLAUDE.md` → `~/.claude/CLAUDE.md` (global instructions for all projects)
- Plugins: playwright, github, layered-rails, solargraph (local)
- Hooks (all `bin/` scripts, symlinked to `/usr/local/bin` by `install.sh`):
  - `workmux-claude-status` — reports agent status to the right tmux pane
  - `claude-session-retro-hook` — on PreCompact/SessionEnd, drafts a read-only
    session retro into `~/.claude/retro-inbox/` (proposes only, never writes
    CLAUDE.md or memory)
  - `claude-retro-inbox-notice` — announces pending retro proposals at SessionStart

### Tool Conventions
- Shell plugin manager: Antigen (`.antigenrc`)
- `macos.zsh` uses idempotent `if ! command -v X` guards — follow this pattern when adding new tools
- Aliases go in `aliases.zsh`
- `cd` is aliased to `zoxide`, `ls` to `eza`
