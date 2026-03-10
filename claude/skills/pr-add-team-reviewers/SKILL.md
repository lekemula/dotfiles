---
name: pr-add-team-reviewers
description: Add team reviewers to GitHub pull requests
disable-model-invocation: false
allowed-tools: Bash
---

Add team reviewers to GitHub pull request(s).

## When to use it?

Use this skill when creating PRs for any of the `~/Projects/finlink/*` repositories.

## Team Members

The following reviewers should be added (excluding the PR author):
- arslanaly47
- hludl
- kzutronic
- lekemula
- mudasirraza
- RomanMukhin
- ZulqarnainNazir

## Instructions

1. Parse `$ARGUMENTS` to identify the PR(s) to update:
   - Can be PR number(s): `1051`, `1051 1052 1053`
   - Can be PR URL(s): `https://github.com/Owner/repo/pull/1051`
   - Can be "current" or empty to use the current branch's PR

2. For each PR:
   - Determine the repository (from URL, or use current repo)
   - Get the PR author using: `gh pr view <number> --repo <owner/repo> --json author --jq '.author.login'`
   - Filter out the author from the reviewers list
   - Add reviewers using: `gh pr edit <number> --repo <owner/repo> --add-reviewer <comma-separated-list>`

3. Report success for each PR with its URL

## Examples

```bash
# Single PR in current repo
gh pr edit 1051 --add-reviewer arslanaly47,hludl,kzutronic,mudasirraza,RomanMukhin,ZulqarnainNazir

# PR in specific repo
gh pr edit 1051 --repo LoanLink/coba-integrations --add-reviewer arslanaly47,hludl,kzutronic,mudasirraza,RomanMukhin,ZulqarnainNazir

# Current branch's PR
gh pr edit --add-reviewer arslanaly47,hludl,kzutronic,mudasirraza,RomanMukhin,ZulqarnainNazir
```
