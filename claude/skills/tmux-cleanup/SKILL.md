---
name: tmux-cleanup
description: Tidy the user's tmux and workmux setup in one pass - reorder windows to the tmux-workspace order, remove worktrees whose PRs are merged, regroup worktree windows into one tmux session per epic/parent ticket, and summarise pending PRs/worktrees. Use whenever the user says cleanup tmux, tidy my tmux, tmux-cleanup, prune merged worktrees, regroup my windows by epic, or asks what PRs/worktrees are still pending, even if they only ask for one of the four steps.
---

The helper scans every tmux session (`tmux list-panes -a`) and every repo any pane is sitting in, so it needs no session argument and works wherever it is run. Run the steps in order; each is independent, so skip any the user did not ask for. All mechanics live in a Ruby helper so the steps behave the same every run:

```
S=~/dotfiles/claude/skills/tmux-cleanup/scripts/tmux_cleanup.rb
```

`$S` below is shorthand only: spell the path out in every command (`ruby ~/dotfiles/claude/skills/tmux-cleanup/scripts/tmux_cleanup.rb reorder`), never through a shell variable. The headless `tmc` alias allowlists exactly that command prefix.

Destructive subcommands (`merged`, `group`) are dry-run unless `--apply` is passed. Preview first, then apply.

## 1. Reorder

`ruby $S reorder` moves windows into the order that `~/dotfiles/bin/tmux-workspace` creates them. Worktree windows (not in the script) follow, in their existing relative order. It is idempotent.

## 2. Remove merged worktrees

`ruby $S merged` lists worktrees with a merged PR and a verdict:
- `REMOVE` - merged, clean tree, every local commit is in the PR head. Safe.
- `KEEP` - merged but dirty or holding commits the PR lacks. Never remove these; report them.

Closed-unmerged PRs and worktrees without a PR are not listed and must stay: the user may still want that work.

Run `ruby $S merged --apply` to remove the `REMOVE` ones (it calls `workmux remove -f`, which also closes the window and drops the branch). The user asked for this cleanup, so apply without a further prompt, but state what was removed.

### Stale windows

`workmux remove` only closes a window in the session recorded in the worktree's git config (`workmux.worktree.<name>.window-session`). `merged --apply` and `group --apply` re-point that at the window's current session, so `workmux remove` closes moved windows too. Windows can still linger when a worktree was removed some other way (e.g. `git worktree remove`), pointing at a deleted or `.workmux_trash_*` directory. After step 2, run `ruby $S stale` to list windows with any pane in a missing directory or an unregistered `*__worktrees/*` path, then `ruby $S stale --apply` to kill them. Detached-HEAD worktrees are still registered, so they are not flagged.

## 3. Regroup by epic / parent ticket

The user keeps one tmux session per epic (or per main ticket, with its subtasks as windows), named by ticket key, e.g. `LI-2025`.

1. `ruby $S tickets` prints the ticket keys of all worktree windows.
2. Resolve each key's grouping ticket with the Atlassian MCP (`mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`, e.g. `key in (LI-1861, LI-2021)`, fields `parent`, `issuetype`): the epic if it has one, else the parent if it is a subtask, else the ticket itself. Do not guess from branch names.
3. Write `{ "LI-2021": "LI-2025", ... }` to a temp file (`$CLAUDE_JOB_DIR/tmp/map.json` in a background job, else `/tmp/tmux-cleanup-map.json`) and run `ruby $S group --map FILE`.
4. Apply with `--apply`. Windows move into the session named after the group, creating it if missing and reusing an existing one. A ticket with a single window and no mapping stays where it is.

If Jira is unreachable, skip this step and say so rather than grouping by branch prefix alone.

## 4. Summarise

`ruby $S summary` prints a markdown table (ticket, repo, worktree, PR state, PR link, tree clean/dirty). Present it grouped by ticket, and call out: open PRs, draft PRs, worktrees with no PR, and dirty trees. End with the result of steps 1-3 (what moved, what was removed, what was kept and why).
