---
name: rex-cleanup
description: Tidy the user's Rex terminal sessions and workmux worktrees in one pass - reorder tabs to the rex-workspace order, remove worktrees whose PRs are merged and close their tabs, regroup worktree tabs into one Rex session per epic/parent ticket, and summarise pending PRs/worktrees. Use whenever the user says cleanup rex, tidy my rex sessions, rex-cleanup, prune merged worktrees in Rex, regroup my Rex tabs by epic, or asks what PRs/worktrees are still pending while working in Rex, even if they only ask for one of the four steps.
---

The Rex counterpart of `tmux-cleanup`. The helper reads every tab in every Rex session (`rex window ls`, plus each pane's foreground program and directory) and every repo any pane sits in, so it needs no session argument. Run the steps in order; each is independent, so skip any the user did not ask for:

```
S=~/dotfiles/claude/skills/rex-cleanup/scripts/rex_cleanup.rb
```

`$S` below is shorthand only: spell the path out in every command (`ruby ~/dotfiles/claude/skills/rex-cleanup/scripts/rex_cleanup.rb reorder`), never through a shell variable.

Destructive subcommands (`merged`, `stale`, `group`) are dry-run unless `--apply` is passed. Preview first, then apply. The tab the helper runs in (`$REX_BLOCK`) is never closed or moved.

## 1. Reorder

`ruby $S reorder` moves tabs into the order `~/dotfiles/bin/rex-workspace` creates them. Other tabs (worktrees) follow, in their existing relative order. It is idempotent.

## 2. Remove merged worktrees

`ruby $S merged` lists worktrees with a merged PR, the Rex tabs sitting in each, and a verdict:
- `REMOVE` - merged, clean tree, every local commit is in the PR head. Safe.
- `KEEP` - merged but dirty or holding commits the PR lacks. Never remove these; report them.

Closed-unmerged PRs and worktrees without a PR are not listed and must stay: the user may still want that work.

Run `ruby $S merged --apply` to remove the `REMOVE` ones: `workmux remove -f` drops the worktree, branch and its background tmux window, and the helper closes the worktree's Rex tabs. The user asked for this cleanup, so apply without a further prompt, but state what was removed.

After step 2, run `ruby $S stale` to list tabs with any pane in a missing directory or an unregistered `*__worktrees/*` path (a worktree removed some other way), then `ruby $S stale --apply` to close them.

## 3. Regroup by epic / parent ticket

The user keeps one session per epic (or per main ticket, with its subtasks as tabs), named by ticket key, e.g. `LI-2025`.

1. `ruby $S tickets` prints the ticket keys of all worktree tabs.
2. Resolve each key's grouping ticket with the Atlassian MCP (`mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`, e.g. `key in (LI-1861, LI-2021)`, fields `parent`, `issuetype`): the epic if it has one, else the parent if it is a subtask, else the ticket itself. Do not guess from branch names.
3. Write `{ "LI-2021": "LI-2025", ... }` to a temp file (`$CLAUDE_JOB_DIR/tmp/map.json` in a background job, else `/tmp/rex-cleanup-map.json`) and run `ruby $S group --map FILE`.
4. Apply with `--apply`.

Rex cannot move a tab between sessions, so `group` recreates each tab in the target session (same label, pane directories and split ratios) and closes the original, creating the session if missing. Only tabs whose panes are idle shells move; tabs running nvim, claude or anything else are listed as `SKIP` with what runs there. Report those so the user can quit the programs and rerun, rather than moving them some other way.

If Jira is unreachable, skip this step and say so rather than grouping by branch prefix alone.

## 4. Summarise

`ruby $S summary` prints a markdown table (ticket, repo, worktree, PR state, PR link, tree clean/dirty, Rex session). Present it grouped by ticket, and call out: open PRs, draft PRs, worktrees with no PR, and dirty trees. End with the result of steps 1-3 (what moved, what was removed, what was skipped or kept and why).
