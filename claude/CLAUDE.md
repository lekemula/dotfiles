# Global Preferences

## General
- Be concise. Skip obvious explanations.
- Don't add method comments unnecessarily. Only add comments for non-obvious code.
- Comments carry context that's hard to infer from the code, not rationale aimed at reviewers. Don't justify implementation decisions in a comment — that belongs in the PR description or commit body.
- Run tests/specs/linters after making changes to ensure nothing is broken.
- Don't commit or push unless I ask.
- Avoid unexpanded acronyms (ECD, LoA, etc.) in titles, headings, commit subjects, and PR/ticket titles. In long-form bodies, expand on first use — e.g. `ExternalCreditDecision (ECD)` — then reuse the short form. Code identifiers like `PROCESS_STATUS_ERROR` are not acronyms; use them as-is.

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
- Use the `atlassian-toolkit` plugin skills (`jira-api`, `confluence-api`, `jira-fetch`) **only** for uploading and downloading attachments — that's the one thing the MCP can't do. Use the Atlassian MCP (`mcp__claude_ai_Atlassian__*`) for everything else: reading issues, JQL search, comments, transitions, Confluence pages.
- Gotchas when you do need the skills: `scripts/secrets.sh` uses bash-only `${!var}` indirection, so source it via `bash -c` (plain zsh dies with `bad substitution`). Its `use_atlassian_product jira` prefers `JIRA_API_TOKEN` over `ATLASSIAN_API_TOKEN`, so a stale per-product token silently shadows a working shared one — and Jira answers `404` (not `401`) for unauthenticated reads of a private issue, which reads as "ticket doesn't exist". Check auth with `/rest/api/3/myself` before believing a 404.
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
- To put a screenshot in a PR description or comment, use `gh image` — it uploads from the CLI and prints ready-to-paste markdown pointing at a real `user-attachments/assets/<uuid>` URL that renders for private repos too:
  ```bash
  gh image check-token                     # verify; prints token source + username
  gh image --repo OWNER/REPO shot.png      # prints ![shot.png](https://github.com/user-attachments/...)
  gh image download <user-attachments-url> # reverse direction
  ```
  It authenticates with a **browser session cookie** (or `GH_SESSION_TOKEN`), not a PAT — that is how it reaches the web upload flow. Don't conclude CLI image upload is impossible: a plain PAT / `gh api` genuinely can't do it, and `raw.githubusercontent.com` links don't render for private repos (the camo image proxy can't authenticate), but `gh image` sidesteps both. Upload first, then splice the returned markdown into the body file and `gh pr edit <n> --body-file`.
- `gh image` covers GitHub only — Jira attachments still need a working Atlassian API token, since the Atlassian MCP cannot upload attachments at all.

### PR descriptions
Keep them minimal. Follow the repo's `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`) when one exists — it wins over the shape below.

With no template, use these sections and omit any that don't apply:
- `### Ticket` — Jira ticket link, or the `NO-REF` branch prefix. Omit the section entirely if neither applies.
- `### Purpose` — why, in a line or two.
- `### Approach` — a few one-line bullets summarizing the change. High-level components only, never a file-by-file walkthrough. Order the bullets the way a reviewer should read the PR.
- `### Review notes` — only to say the PR is best reviewed commit-by-commit, when the commits are atomic. Omit otherwise.
- `### Testing` — high-level user interface steps if applicable; `rake` task snippets for prerequisites or when the PR changes local dev tooling; related end-to-end tests added in other PRs/repos (e.g. `loanlink-web`). Never mention that unit tests pass — that is a given.

No narrative walkthroughs, no speculative caveat lists, no "future improvements" section.

## Worktrees
- Worktrees are workmux's job. It keeps them in a sibling `<project>__worktrees/<name>` with a tmux window and agent status tracking attached — reuse those instead of creating a parallel `.claude/worktrees/` copy of the same repo.
- Need isolation: run `workmux list` first and enter an existing worktree by its path (`workmux path <name>` resolves it); only `workmux add <name>` a new one if none fits. Entering it counts as isolating, so background jobs don't need their own `.claude/worktrees/` copy.
- Clean up with `workmux merge` or `workmux remove`, not `git worktree remove` — those also close the tmux window and drop the branch.
- Don't hand-roll `git worktree add`.

## Environment
- macOS, zsh, Neovim, tmux, iTerm2
- Shell plugin manager: Antigen
- Dotfiles at ~/dotfiles
  - When adding a new tool, or changing config files, make sure you edit the ~/dotfiles repo and add the necessary symlinks in install.sh
