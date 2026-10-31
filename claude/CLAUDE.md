# Global Preferences

## General
- Be concise. Skip obvious explanations.
- Don't add method comments unnecessarily. Only add comments for non-obvious code.
- Comments carry context that's hard to infer from the code, not rationale aimed at reviewers. Don't justify implementation decisions in a comment. Line-level rationale — why this parse, why this guard, why not the obvious alternative — goes in an inline GitHub comment on the diff. Only the high-level approach belongs in the PR description or commit body.
- Inline GitHub comments post under my account, so start every one with a marker making clear it is the agent talking, not me: `> 🤖 **Claude Code (AI agent)** — written by the agent, not by the PR author.` Write them in the third person too — no "I tried X", which reads as me having tried it. Keep them human-readable and as compact as possible: a few short sentences of plain language, one idea per paragraph, two or three paragraphs at most. Reviewers stop reading a dense one, so length defeats the point of moving the rationale onto the diff.
- Run tests/specs/linters after making changes to ensure nothing is broken.
- When I answer only some questions in a round of questions (grilling, clarifications), take your recommended answer for the ones I skipped instead of asking them again.
- Don't commit or push unless I ask.
- Avoid unexpanded acronyms (ECD, LoA, etc.) in titles, headings, commit subjects, and PR/ticket titles. In long-form bodies, expand on first use — e.g. `ExternalCreditDecision (ECD)` — then reuse the short form. Code identifiers like `PROCESS_STATUS_ERROR` are not acronyms; use them as-is.
- Whenever the outcome is a list of things **I** have to do by hand — seed data to edit, dashboard steps, a migration runbook, anything I work through item by item — publish it as an Artifact checklist instead of leaving it in the terminal. Give each item what to set, where, and the current vs. target value, and say plainly which items to skip and why. A table in chat scrolls away; a checklist I can tick off does not.

## Skills
- Any helper script bundled inside a skill you author (SKILL.md directories under `~/.claude/skills/` or a repo's `.claude/skills/`) must be written in Ruby, not Python/bash/etc. — easier for me to review. Plain `bash`/CLI one-liners inline in skill steps are fine; this is about actual standalone scripts (e.g. a `scripts/*.rb` file a skill shells out to).

## Ruby / Rails
- Primary stack: Ruby on Rails
- Version manager: mise (handles Ruby, Node, and other tools)
- Testing: RSpec
- Debugging: debugger
- Linting: RuboCop - run after changes to Ruby files
- Follow existing project conventions over style guide defaults

## Credentials
- `BUNDLE_RUBYGEMS__PKG__GITHUB__COM` (GitHub Packages auth for the private `rubygems.pkg.github.com/LoanLink` gem source, needed for `bundle install` in LoanLink Ruby repos) lives in `~/.zshrc.secrets` and is already present in any shell — check with `[ -n "$BUNDLE_RUBYGEMS__PKG__GITHUB__COM" ]` before assuming it's missing, and pass it through explicitly to `docker exec` when installing inside a container. Don't go hunting other credential stores for this or similar tokens — ask if it's not found here.

## Jira / Confluence
- Writing ticket **content** always goes through the `jira-ticket` skill — creating a ticket, or
  editing an existing ticket's summary/description (context, acceptance criteria, test section).
  Never hand-write those with a bare `createJiraIssue`/`editJiraIssue` call; the
  `claude-jira-skill-gate` hook blocks it. Field-only edits (labels, assignee, sprint,
  transitions) and plain comments are exempt.
- Use the `atlassian-toolkit` plugin skills (`jira-api`, `confluence-api`, `jira-fetch`) **only** for uploading and downloading attachments — that's the one thing the MCP can't do. Use the Atlassian MCP (`mcp__claude_ai_Atlassian__*`) for everything else: reading issues, JQL search, comments, transitions, Confluence pages.
- Screenshots and images on a ticket go **inline in the description**, never attachment-only — embed with `!filename|thumbnail!` and mention it in the prose as `[^filename]` so it is both visible and linked. The description field on these projects uses the **wiki renderer**, so write it via REST `api/2` with wiki markup: `api/3` hands back a lossy ADF conversion (`h3.` as literal text, `#` items as headings) and writing ADF to it mangles the formatting. Keep `#` list items on consecutive lines — a blank line between them turns each into an `<h1>`.
- Before an Atlassian auth or token step (a 401/404 from Jira, a skill call failing auth, rotating a token), read `~/.claude/docs/atlassian-credentials.md`: tokens live in two places and several failures look like something else.

## Notes (LogSeq)
- For ad-hoc investigations with no ticket, save the important outcomes to LogSeq: findings, decisions, open questions, Mermaid diagrams and graphs. For ticketed work, Jira is the source of truth: put those notes on the ticket, not in LogSeq.
- Work-related notes go in the **Work - Finlink** graph at `~/Documents/Logseq/Work - Finlink/`. Make one page per investigation under `pages/<Title>.md`. Whenever you create a new page, also add a one-line `[[<Title>]]` entry to the Daily Journal page for the date the work **started**, not the date you happen to write the note (`journals/YYYY_MM_DD.md`; append if the page exists, create it if not).
- Match the graph's format: a Markdown outline with tab-indented `- ` blocks and `key:: value` page properties at the top. For Mermaid, use a plain fenced ```` ```mermaid ```` block nested under a bullet. `logseq-fenced-code-plus` renders it, so don't add `{{renderer :mermaid_…}}` macros, `mermaid.ink` image previews or `%%{init}%%` directives. Inside the diagram, indent with 2 spaces per level (subgraph contents, participants, messages), and leave out blank lines inside the block.
- LogSeq writes its in-memory copy of an open page back over outside edits. Backups land in `logseq/bak/pages/<page>/`. After editing a page file, tell me to reload or re-index the page in LogSeq, and don't treat what LogSeq shows as the file's content until then.

## Docker
- Use Docker for development and testing when possible
- Use docker-compose for multi-container applications
- Prefer one-time run commands (docker run --rm) for ad-hoc tasks
- Keep Dockerfiles simple and efficient (multi-stage builds, minimal base images)

## Git
- Commit messages: short, imperative, lowercase (e.g., "fix login redirect")
- Add detailed descriptions in the body of the commit message when necessary
- Rebase workflow (pull.rebase = true, autoSquash, updateRefs)
- Keep commits atomic: one problem per commit. A reviewer should be able to read the branch commit by commit, and any commit (or run of commits) should lift cleanly into its own PR if the branch grows too large.
  - Don't mix concerns. A refactor, a rename, a formatting pass, a dependency bump and the behaviour change they enable are separate commits, prep commits first.
  - Each commit leaves the tree working (tests and linters pass) and carries its own specs.
  - Stage by hunk (`git add -p`) when one file holds changes for more than one commit.
  - Follow-ups to an earlier commit on the branch — review fixes, missed specs, typos, lint — go in as `git commit --fixup=<sha>` (`--squash` if the message changes too), folded with `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`. Never leave "fix tests", "address review" or "wip" commits standing.
  - Keep git's default `fixup! <original subject>` line, but never leave the body empty: describe what the change is about and why in the description (`git commit --fixup=<sha> -m "<what changes and why>"` puts it under the default subject). When the final message itself changes, use `git commit --fixup=amend:<sha>` or an `amend!` commit with the new message.
  - Fixup and squash hard: the final history is a handful of lean, self-explanatory commits, not a log of how the work happened.
  - Rewriting already-pushed history needs a force-push — ask first, and use `--force-with-lease`, never plain `--force`.
- Push by name: `git push origin <branch>` (the github-toolkit hook rejects a bare `git push`; autoSetupRemote sets up tracking on the first push)
- Wait for confirmation before commiting and pushing to remote branches
- Push at the very last stage. Finish everything locally first — code, specs, e2e and manual verification, commit reshaping, PR text. When the work spans several repos or PRs, push them all together at the end, and postpone every push until all of them are complete locally. Don't push a branch early "so a PR exists" or to unblock one step.
- To put a screenshot or video in a PR/issue description or comment, use `gh`'s built-in `--attach` (gh 2.99.0+). It uploads over your normal `gh auth` login and yields a real `user-attachments/assets/<uuid>` URL that renders for private repos too:
  ```bash
  gh pr create  --attach './before.png#The login error state'   # alt text after "#"
  gh pr edit 23 --attach ./before.png --attach ./after.png      # repeatable, max 50/command
  gh pr comment 23 --attach ./repro.mp4
  # same flag on gh issue create / edit / comment
  ```
  If the body already references the local path (`![alt](./before.png)`), that reference is rewritten in place — so write the body file with plain local paths and pass `--body-file body.md --attach ./before.png` in one go, no upload-then-splice step. Unreferenced attachments get appended to the end, in flag order. Needs push access to the repo; images and video only; the same file can't be attached twice; video takes no alt text and its reference must be the only thing in its paragraph. GitHub.com and Enterprise Cloud only. Don't fall back to `raw.githubusercontent.com` links — they don't render for private repos, because the camo image proxy can't authenticate. Full docs: https://docs.github.com/en/github-cli/github-cli/attaching-files-with-github-cli
- `--attach` covers GitHub only — Jira attachments still need a working Atlassian API token, since the Atlassian MCP cannot upload attachments at all.

### PR descriptions
Before writing or editing a PR description, read `~/.claude/docs/pr-descriptions.md`.

## Worktrees
- Worktrees are workmux's job. It keeps them in a sibling `<project>__worktrees/<name>` with a tmux window and agent status tracking attached — reuse those instead of creating a parallel `.claude/worktrees/` copy of the same repo.
- Need isolation: run `workmux list` first and enter an existing worktree by its path (`workmux path <name>` resolves it); only `workmux add <name>` a new one if none fits. Entering it counts as isolating, so background jobs don't need their own `.claude/worktrees/` copy.
- **Parallel work gets its own tmux session.** When a work stream spans several worktrees — subtasks of one ticket, or several epics tackled at once — give each stream its own tmux session named after its ticket key (e.g. `LI-2025`, one per epic), and put each subtask's worktree in as a window of that session. This keeps the main session uncluttered and lets me find a stream by name in the session list. A one-off worktree stays a window in the current session.
  - Create the session if it's missing, then add into it: `tmux has-session -t LI-2025 2>/dev/null || tmux new-session -d -s LI-2025 -c <repo>`, then `workmux add --parent-session LI-2025 --background <branch>`. Without `--parent-session`, workmux places the window in the caller's session, and with no tmux pane (background jobs) and several sessions it refuses outright.
  - Reuse an existing session for the stream (`tmux ls`) instead of creating a second one.
- Clean up with `workmux merge` or `workmux remove`, not `git worktree remove` — those also close the tmux window and drop the branch.
- Don't hand-roll `git worktree add`.
- When starting work in a worktree, always `git fetch` and rebase onto `main` first. A worktree cut earlier can be well behind, and a dependency the task needs may already have merged — rebasing is what makes it available, and it avoids building a scratch worktree to combine branches that `main` already combines.
- **Talk to worktree agents with the built-in cross-session messaging, not `workmux send`.** `ListAgents` discovers addressable sessions, `SendMessage` reaches one. Keep workmux for what only it does: `add` to spawn a worktree plus tmux window, `status`/`wait` for lifecycle, `merge`/`remove` to clean up. `workmux send` types into a pane and returns nothing — no delivery confirmation, no reply path, so reading an answer means scraping scrollback with `workmux capture`, which truncates and interleaves UI chrome. When coordinating, ask spawned agents to report back via `SendMessage` to the coordinator's session name (it shows in their `ListAgents` output).
  - A `SendMessage` message id confirms **queuing, not delivery**: the recipient's permission settings can hold it for their user's approval, which surfaces later as a delivery notice. Verify it landed rather than assuming. `workmux send` is the fallback that bypasses the gate, since it only types into a pane.
  - `workmux status` reports `done` whenever a main agent idles between subagent turns, so it is not a completion signal. Trust the agent's own message, or a real artefact such as a lock owner file.
- A shared repo checkout is a coordination hazard when several worktree agents need it (e.g. one `loanlink-web` serving many `ehyp-integrations` worktrees). Give each agent its own worktree of that repo rather than switching branches or stashing under another session's uncommitted work.

## Environment
- macOS, zsh, Neovim, tmux, iTerm2
- Shell plugin manager: Antigen
- Dotfiles at ~/dotfiles
  - When adding a new tool, or changing config files, make sure you edit the ~/dotfiles repo and add the necessary symlinks in install.sh
