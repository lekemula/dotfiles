---
name: summarise-pr-review-comments
description: Summarise the user's pending GitHub PR review comments grouped by theme. Use when asked to summarise, group, or recap pending review comments on a pull request.
disable-model-invocation: false
allowed-tools: Bash, AskUserQuestion
---

Summarise the user's pending review comments on a GitHub pull request, grouped into a few high-level themes so the user can post (or paste) a coherent review summary.

## Arguments

Usage: `/summarise-pr-review-comments $ARGUMENTS` where `$ARGUMENTS` is a PR URL or number. Examples:

- `/summarise-pr-review-comments 14662`
- `/summarise-pr-review-comments https://github.com/LoanLink/loanlink-api/pull/14662`
- `/summarise-pr-review-comments LoanLink/loanlink-api#14662`

If no argument is provided, ask which PR to summarise (or use the current branch's PR via `gh pr view --json number,url`).

## Steps

### 1. Resolve repo + PR number

- Parse `$ARGUMENTS` to extract `owner/repo` and PR number.
- If only a number is given, default to the current repo: `gh repo view --json nameWithOwner -q .nameWithOwner`.
- If nothing is given, fall back to `gh pr view --json number,url` for the current branch.

### 2. Find the user's pending review

The pending review belongs to the authenticated user. Fetch the user, then look for a `PENDING` review they own:

```bash
ME=$(gh api user --jq .login)
gh api repos/<owner>/<repo>/pulls/<number>/reviews \
  --jq ".[] | select(.state == \"PENDING\" and .user.login == \"$ME\") | .id"
```

- If no pending review exists, tell the user and stop (offer to summarise *submitted* comments instead).
- If multiple pending reviews exist, list them and ask which one.

### 3. Fetch the pending comments

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews/<review-id>/comments \
  --jq '.[] | {path, line, body}'
```

Read every `body` carefully. Group them by file only as a reference — the *summary itself* should group by theme, not by file.

### 4. Cluster into themes

Cluster comments by the kind of feedback they give, not the file they live in. Typical themes:

- **Trim/clean comments** — redundant code comments that restate the code.
- **Misplaced logic / responsibilities** — code that belongs in another class/service/layer.
- **Naming / terminology** — clearer or more business-oriented names.
- **Design questions** — sync vs async, propagation, redundant calls, etc.
- **Avoiding shortcuts** — e.g. `validate: false`, parallel attributes, AI-flavoured workarounds.
- **Logging / observability** — adopt structured logging, etc.
- **Frontend vs backend concern** — logic that belongs on the other side.
- **Small refactors / nits** — suggestions, renames, signature tweaks.

Pick whichever themes actually fit; do not force comments into a theme that does not match. A theme with one comment is fine if it stands alone.

### 5. Ask the user what they want

Use `AskUserQuestion` to offer:

- **Bullet themes** (default) — high-level themes only, no per-comment detail.
- **Themes + per-comment detail** — themes with the underlying comments listed under each.
- **Ready-to-paste review body** — a markdown block the user can paste into the review summary field on GitHub.

### 6. Produce the output

- Keep the summary tight. Themes are short headers + one sentence.
- For the ready-to-paste version, output a single fenced markdown block so the user can copy it cleanly.
- Do not invent comments the user did not write. Only summarise what is in the pending review.
- Do not submit the review. The user submits it themselves.

## Guidelines

- Always summarise **the user's own pending comments**, not other reviewers' comments.
- Never call `gh pr review --submit` or otherwise publish the review.
- If a comment is a GitHub `suggestion` block, capture the *intent* of the suggestion in the theme, not the diff itself.
- When the same point appears in multiple comments, collapse it into a single theme entry rather than repeating.
- Keep tone neutral and constructive — the summary is a recap, not a re-litigation.
