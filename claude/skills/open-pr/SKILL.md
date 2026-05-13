---
name: open-pr
description: Open a GitHub pull request with summary, reviewers, and optional pre-checks. Use when asked to open, create, or draft a PR/pull request.
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

Open a GitHub pull request for the current branch.

## Arguments

Usage: `/open-pr $ARGUMENTS` where `$ARGUMENTS` is a branch or a PR number to use as the base for the PR. Examples:
- `/open-pr origin/main`
- `/open-pr main`
- `/open-pr 1051` (if you want to open a PR against the branch of PR #1051)
- `/open-pr https://github.com/LoanLink/loanlink-api/pull/14103/` (if you want to open a PR against the branch of that PR)

- **Optional argument**: Base branch to diff against (e.g., `origin/main`, `origin/master`, `main`). Defaults to `origin/main` or `origin/master` (whichever exists).

## Steps

### 1. Determine base branch

- If `$ARGUMENTS` is provided, use it as the base branch.
- Otherwise, detect the default: check which of `origin/main` or `origin/master` exists via `git branch -r`.
- Confirm the base branch with the user if neither is found.

### 2. Summarise changes

Run the following to understand what's changed:

```bash
git log <base-branch>...HEAD --oneline
git diff <base-branch>...HEAD --stat
git diff <base-branch>...HEAD
```

Read and understand:
- Which files changed and why
- What commits are included
- The overall intent and impact of the changes

### 3. Load PR template (if present)

Check for `.github/PULL_REQUEST_TEMPLATE.md` in the repo root:
- If it exists, read it and use its structure for the PR body
- Fill in all sections meaningfully based on the actual changes
- Do not leave placeholder text unfilled
- Exclude "how to test" instructions on running specs or linting; focus instead on explaining what was tested and how to validate the changes.

### 4. Check for pre-commit hooks

```bash
ls .git/hooks/pre-commit 2>/dev/null || echo "none"
cat .pre-commit-config.yaml 2>/dev/null || echo "none"
```

If **no pre-commit hooks are configured**, run checks against changed files:

```bash
# Get list of changed files
git diff <base-branch>...HEAD --name-only
```

- **Specs**: If any `*_spec.rb` or `spec/**` files exist or changed files have corresponding specs, run:
  ```bash
  bundle exec rspec <relevant spec files>
  ```
- **Linting**: If Ruby files changed:
  ```bash
  bundle exec rubocop <changed .rb files>
  ```
- **JavaScript/TypeScript**: If JS/TS files changed, check for and run the project's lint command (e.g., `npm run lint`, `yarn lint`).
- Report any failures and stop — do not proceed to create the PR until checks pass or the user explicitly confirms to skip.

### 5. Draft PR title and body

- **Title**: Short, imperative, lowercase (e.g., "add user export feature"). Under 70 characters.
    - Include the Jira ticket key if applicable (e.g., "LL-1234 add user export feature").
- **Body**: Fill in the PR template if present, or use this default structure:

```markdown
## Purpose

- [bullet points describing the problem and why we need the changes]

## Approach

- [bullet points describing how the change was implemented, key design decisions, and any trade-offs]

## Test plan

- [ ] [what was tested / how to verify]
```

### 6. Identify reviewers

- Check the `pr-add-team-reviewers` skill for the project's team reviewer list, if applicable.
- Otherwise, suggest reviewers based on `git log` authors of recently changed files:
  ```bash
  git log <base-branch>...HEAD --format='%ae' | sort | uniq
  git log --follow -n 5 --format='%ae' -- <changed files>
  ```
- Map emails to GitHub usernames where possible using `gh api`.

### 7. Preview and confirm

Display a preview of the PR to the user:

```
Title: <title>
Base:  <base-branch>
Head:  <current-branch>
Reviewers: <list>

Body:
---
<body>
---
```

Use AskUserQuestion to ask: **"Ready to create this PR? (yes / edit / cancel)"**

- **yes**: proceed to create
- **edit**: ask what to change, update the draft, preview again
- **cancel**: stop

### 8. Create the PR

```bash
gh pr create \
  --base <base-branch-without-origin-prefix> \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)"
```

Report the PR URL when done.

## Guidelines

- Strip the `origin/` prefix when passing the base branch to `gh pr create --base`.
- Never create the PR without explicit user confirmation.
- If checks fail, report clearly which files/tests failed and ask whether to proceed anyway.
- Keep the PR title lowercase and imperative (matches commit message style).
- Do not invent reviewers — only suggest those found in git history or the team list.
