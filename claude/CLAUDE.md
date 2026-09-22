# Global Preferences

## General
- Be concise. Skip obvious explanations.
- Don't add method comments unnecessarily. Only add comments for non-obvious code.
- Comments carry context that's hard to infer from the code, not rationale aimed at reviewers. Don't justify implementation decisions in a comment. Line-level rationale — why this parse, why this guard, why not the obvious alternative — goes in an inline GitHub comment on the diff. Only the high-level approach belongs in the PR description or commit body.
- Inline GitHub comments post under my account, so start every one with a marker making clear it is the agent talking, not me: `> 🤖 **Claude Code (AI agent)** — written by the agent, not by the PR author.` Write them in the third person too — no "I tried X", which reads as me having tried it. Keep them human-readable and as compact as possible: a few short sentences of plain language, one idea per paragraph, two or three paragraphs at most. Reviewers stop reading a dense one, so length defeats the point of moving the rationale onto the diff.
- Run tests/specs/linters after making changes to ensure nothing is broken.
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
- Gotchas when you do need the skills: `scripts/secrets.sh` uses bash-only `${!var}` indirection, so source it via `bash -c` (plain zsh dies with `bad substitution`). Its `use_atlassian_product jira` prefers `JIRA_API_TOKEN` over `ATLASSIAN_API_TOKEN` but pairs whichever it picks with the single `ATLASSIAN_EMAIL`, so a Jira token belonging to a *different account* silently breaks auth — it is not expiry, and rotating it fixes nothing. My dev-pal token authenticates as the `it@finlink.de` technical user, so it lives in `~/.zshrc.secrets` as `DEVPAL_JIRA_API_TOKEN` and `aliases.zsh` injects it as `JIRA_API_TOKEN` for `fl`/`dev-pal` only — never export that name globally again. Jira also answers `404` (not `401`) for unauthenticated reads of a private issue, which reads as "ticket doesn't exist"; check auth with `/rest/api/3/myself` **and confirm the `displayName` it returns is the account you meant** before believing a 404.
- Atlassian credentials live in **two** places that must be kept identical: `~/.zshrc.secrets` (for the terminal) and the `env` block of `~/.claude/settings.local.json` (for Claude Code tool calls, which do not source `.zshrc.secrets`). Both hold `ATLASSIAN_BASE_URL`, `ATLASSIAN_EMAIL` and `ATLASSIAN_API_TOKEN`. Rotate them together — a drifted copy is how a dead token hid for months. With the `env` block populated, the skills read these straight from the environment, so there is no need to source `scripts/secrets.sh` (and no need for the `bash -c` workaround) just to get credentials.
- Scoped Atlassian tokens (created with explicit scopes) only work against `https://api.atlassian.com/ex/jira/<cloudId>`, not `https://<site>.atlassian.net`. Unscoped tokens work against both.

## Docker
- Use Docker for development and testing when possible
- Use docker-compose for multi-container applications
- Prefer one-time run commands (docker run --rm) for ad-hoc tasks
- Keep Dockerfiles simple and efficient (multi-stage builds, minimal base images)

## Git
- Commit messages: short, imperative, lowercase (e.g., "fix login redirect")
- Add detailed descriptions in the body of the commit message when necessary
- Rebase workflow (pull.rebase = true, autoSquash, updateRefs)
- Push sets up remote tracking automatically (autoSetupRemote)
- Wait for confirmation before commiting and pushing to remote branches
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
Keep them compact. Reference: https://github.com/LoanLink/ehyp-integrations/pull/315 — roughly 1.8KB including two screenshots. A description orients a reviewer; it is not the record. Evidence, root-cause analysis and the reasoning behind a decision live on the ticket or a Confluence page and get *linked* from the PR, never restated in it.

The description covers the high-level approach only. Anything that explains a particular hunk goes as an inline comment on that line of the diff — not in the description, and not as a code comment.

Follow the repo's `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`) when one exists — it wins over the shape below.

With no template, use these sections and omit any that don't apply:
- `### Ticket` — Jira ticket link, or the `NO-REF` branch prefix. Omit the section entirely if neither applies.
- `### Purpose` — why, in a line or two.
- `### Approach` — a few one-line bullets summarizing the change. High-level components only, never a file-by-file walkthrough. Order the bullets the way a reviewer should read the PR.
- `### Review notes` — only to say the PR is best reviewed commit-by-commit, when the commits are atomic. Omit otherwise.
- `### Testing` — high-level user interface steps if applicable; `rake` task snippets for prerequisites or when the PR changes local dev tooling; related end-to-end tests added in other PRs/repos (e.g. `loanlink-web`). Never mention that unit tests pass — that is a given.

Show, don't explain — a screenshot or a before/after payload speaks a million words. Proof is the part that earns its space: lead with it and delete the prose it makes redundant. Screenshots and evidence always stay; the paragraphs around them are what gets cut.

Cut on sight: narrative walkthroughs, speculative caveat lists, "future improvements" sections, file-by-file summaries, and collapsed `<details>` blocks — a before/after belongs inline as a couple of lines of code or JSON.

## Worktrees
- Worktrees are workmux's job. It keeps them in a sibling `<project>__worktrees/<name>` with a tmux window and agent status tracking attached — reuse those instead of creating a parallel `.claude/worktrees/` copy of the same repo.
- Need isolation: run `workmux list` first and enter an existing worktree by its path (`workmux path <name>` resolves it); only `workmux add <name>` a new one if none fits. Entering it counts as isolating, so background jobs don't need their own `.claude/worktrees/` copy.
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
