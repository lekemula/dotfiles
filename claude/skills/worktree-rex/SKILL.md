---
name: worktree-rex
description: Launch tasks in new workmux worktrees whose agents run in Rex tabs instead of tmux windows.
disable-model-invocation: true
allowed-tools: Bash, Write
---

Launch one or more tasks in new git worktrees, each opened as a Rex tab (nvim left, claude right).

Tasks: $ARGUMENTS

## You are a dispatcher

Your only job is writing prompt files and running the launcher. The worktree agent explores and implements. Write each prompt from what the user said and the conversation so far; when that is not enough to write one, ask the user.

If a task points at a markdown plan or spec, re-read it so the prompt carries its latest version.

## Steps

For each task:

1. Pick a 2–4 word kebab-case name. Lead with the ticket key when there is one (`LI-2025-retry-webhooks`, or `ENG-000-<desc>` without a ticket): the key names the Rex session the tab lands in.
2. Write the prompt to `$CLAUDE_JOB_DIR/tmp/<name>.md` when that variable is set, else to `mktemp`. It holds the full task description, relative paths only (each worktree has its own root), and what done looks like. When the user passes a skill (`/auto --gemini`), the prompt says `Use the skill: /auto --gemini <task>` instead of implementation steps. Add "Then use the /merge skill to commit, rebase, and merge the branch." only when the user passed `--merge`.
3. After every prompt is written, launch each from the current directory, so the worktree branches from the checked-out branch:

   ```bash
   ruby ~/.claude/skills/worktree-rex/scripts/open_in_rex.rb <name> <prompt-file> [--session <label>]
   ```

   `--session` overrides the Rex session; without it the script uses the ticket key in the name, else the session you are running in. It prints the worktree path, branch and Rex session as JSON.

Done when every launcher call has printed its JSON. Report each branch, worktree path and Rex session to the user.

## How it fits together

workmux still owns each worktree, so `workmux list`, `merge` and `remove` work as usual. It only drives tmux, so the script runs it with `-C` and `--prompt-file-only`: its tmux window (in the background `rex-worktrees` session) is a bare shell, and the agent runs in the Rex tab instead. `workmux remove` closes that tmux window but not the Rex tab; close the tab by hand.
