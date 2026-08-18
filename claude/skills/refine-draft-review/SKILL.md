---
name: refine-draft-review
description: Refine the draft (pending, unsubmitted) GitHub PR review you already typed by hand — fixes typos and phrasing minimally, links code references, adds a real `suggestion` diff only where one genuinely helps, and rewrites each comment in place, leaving the review still pending for you to submit. Use when asked to refine, clean up, polish, or proofread a draft/pending PR review or its comments.
disable-model-invocation: false
allowed-tools: Bash, Read, AskUserQuestion, WebFetch
---

Take the **pending (draft, unsubmitted) review the user already started on GitHub** and rewrite its inline comments in place, lightly cleaned up. Nothing is submitted and nothing is deleted — the review stays `PENDING` for the user to finalize. Comments are plain prose by default — GitHub's own diff view already supplies code context, so don't re-quote it (see step 5).

This is the sibling of `hunk-pr-comment`; the only difference is the **input**. There, notes come from a live Hunk session and are posted as a new pending review. Here, the comments already exist on GitHub as a draft review and are edited in place. Everything about the cleanup pass, linking, and suggestion blocks is the same.

The fetch/edit logic lives in `scripts/draft_review.rb` (Ruby, next to this file) — read it before your first run of this skill so you know what it does; steps 1-2 and 7-8 below just describe how to drive it.

## Arguments

Usage: `/refine-draft-review $ARGUMENTS` where `$ARGUMENTS` is a PR URL or number. Examples:

- `/refine-draft-review 282`
- `/refine-draft-review https://github.com/LoanLink/ehyp-integrations/pull/282`
- `/refine-draft-review LoanLink/ehyp-integrations#282`

If no argument is given, try `gh pr view --json number,url` for the current branch; if that fails, ask which PR.

## Steps

### 1. Resolve the PR and repo

Parse `$ARGUMENTS` for `owner/repo` and PR number. If only a number is given, use the current repo (`gh repo view --json nameWithOwner -q .nameWithOwner`).

```bash
gh pr view <number> --repo <owner>/<repo> --json number,url,headRefName,headRefOid,baseRefName
```

`headRefOid` is what you'll build permalinks from in step 6.

### 2. Fetch the draft review

```bash
ruby ~/.claude/skills/refine-draft-review/scripts/draft_review.rb fetch --repo <owner>/<repo> --pr <number>
```

- Exit code 3 means the user has **no pending review** on this PR. Tell them to start one on GitHub first (add inline comments via "Start a review" rather than "Add single comment") and stop. If they instead have local Hunk notes, point them at `/hunk-pr-comment`.
- The JSON gives you `review` (`id`, `node_id`, `body`, `commit_id`) and `comments` — each with `node_id`, `id`, `path`, `position`, `body`, and `diff_hunk`.
- **A pending comment has no `line`/`side` yet** (GitHub resolves those only at submit time) — the only anchor is `position`, an offset into the file's diff, not a file line number. So `diff_hunk` is your real anchor: its last line is the line the comment points at.
- `diff_hunk` is the code the comment is anchored to. **Use it to understand the note** — it is not something to quote back (step 5).
- If `comments` is empty but a pending review exists, there's nothing to refine; say so and stop.

### 3. Read the code the comments are about

Unlike Hunk notes, these comments arrive with no local session context. Before rewriting anything, read the anchored region of each file (`Read` at `line`, or `gh pr diff <number>`) so the refinement doesn't misread what the comment refers to. Refining a comment you don't understand is how a "cleanup" pass silently changes its meaning.

### 4. Clean up each comment's text

For each comment, do a **light, minimalistic edit pass** — not a rewrite:

- Fix typos and obvious grammar slips (e.g. "seet" → "set", "thuoght" → "thought", "leggit" → "legit").
- Trim filler, but preserve the reviewer's actual wording, tone, and intent as closely as possible.
- Keep nits as nits, questions as questions, suggestions as suggestions — do not upgrade a casual "what's the idea behind this?" into a formal demand.
- Do **not** add new claims, soften/harden the feedback, or merge distinct points into a vaguer one.
- A comment that's already clean needs no edit at all — leave it out of the refinements file entirely rather than rewriting it for the sake of it. The script skips no-op edits anyway, but not listing it is clearer.
- **Watch for `<...>` placeholder hints** — a reviewer sometimes leaves themselves a bracketed note-to-self mid-comment, e.g. `<add a code example>`, `<link this>`, `<expand on why>`. Treat that as an instruction to actually fulfill before posting, not text to clean up around: write the code example, add the link (step 6), or expand the point as directed. Once fulfilled, remove the `<...>` marker itself — it should never survive into the refined comment. If you can't confidently fulfill a hint (e.g. `<add a code example>` but no unambiguous example is inferable), say so when reporting back and leave the placeholder text out rather than leaving a bracketed TODO on GitHub.
- **Do not merge or split comments.** Each pending comment is anchored to a line and can only be edited in place; two comments on the same line stay two comments. (If they read as duplicates, mention it so the user can delete one on GitHub — never delete it yourself.)

### 5. Do NOT add plain "context" code quotes

Learned the hard way: GitHub's inline review UI *already* shows the diff hunk (several lines of surrounding context, colored) directly above every inline comment — that's the very `diff_hunk` the fetch step handed you. A fenced ```ruby block that just re-quotes the current code — with no actual change — is pure redundancy the reviewer has to scroll past, and it's *especially* pointless on wholly-new files (the entire file is green/new in the diff already, so quoting any of it back adds nothing).

**Rule: never add a plain quoted-code block "for context."** If a comment genuinely needs more surrounding code than GitHub's diff view shows (e.g. it references a line 40 rows away from the anchor), say so in prose ("...as used again in `other_method` a few lines below") or link to it (step 6). Only fenced code that belongs in a comment is a real `suggestion` block — see step 7.

### 6. Link code references instead of quoting them

When a comment mentions a specific symbol — a class, method, module, constant — link it rather than pasting its source (pasting would be exactly the redundant quoting step 5 just banned):

- **Internal references** (something defined in this repo): link to its exact GitHub location using a permalink built from the PR's `headRefOid` (the commit SHA from step 1, not the branch name — branches move, commits don't):
  `https://github.com/<owner>/<repo>/blob/<headRefOid>/<path-to-file>#L<line>`
  Find the real line first — `grep -n 'def method_name\|class Name\|MODULE_NAME =' <file>` — never guess a line number. Link the bare file (no `#L`) when the reference is to the whole file/class rather than one specific spot.
- **External / third-party references** (a Rails method, a gem, a language feature — e.g. "Rails' error object," "Rails associations"): link to its official documentation instead — `api.rubyonrails.org` for ActiveModel/ActiveRecord/etc. classes, `guides.rubyonrails.org` for conceptual guides, `ruby-doc.org` for core Ruby, or the gem's own README/rubydoc.info page for anything else. Fetch the target page first to confirm it actually exists and covers what the comment means — never fabricate a doc URL from a guessed naming convention.
- Link inline in the prose (`` Rails' [`ActiveModel::Errors`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html) ``) — one link per reference, not a "References:" footer section.
- Leave links the user already wrote alone.
- If you're not confident a reference resolves cleanly (an ambiguous term, a symbol you can't actually find under that name), skip the link rather than post a wrong or dead one. A missing link is harmless; a broken one looks careless.

### 7. Consider a suggestion block — only for real, non-trivial diffs

Only add a ` ```suggestion ` fenced block (GitHub's inline-fix format) when:

- The comment proposes a **concrete, unambiguous** code change (a rename, an extracted constant, a small restructuring where the resulting code is inferable), **and**
- It's an actual **diff** — the suggested replacement must differ from the current code. Never post a `suggestion` block whose content is identical (or trivially/cosmetically different, e.g. only whitespace) to what's already there.
- It's **not trivial** — a one-word rename buried in a large block, or a change so small the prose comment already conveys it fully, doesn't need a suggestion block on top. Reserve suggestions for changes substantial enough that seeing the actual replacement code saves the reviewer real effort.
- You can write the replacement for the exact anchored line range without guessing at intent not stated in the comment, **and**
- The replacement is self-contained to that anchored line — if making the change correctly requires editing other lines too (e.g. renaming a variable used again a few lines down), a one-line suggestion block would produce broken code. Skip it and leave plain prose instead.

If the comment is a question, a design objection, or a suggestion too open-ended to render as literal replacement code (e.g. "this deserves its own class"), do **not** fabricate a suggestion block. Never invent code the user didn't ask for.

In practice, most comments should end up as **plain prose, no fenced code at all**. A suggestion block is the exception, not the default.

A suggestion block replaces the exact lines the comment is anchored to — a single-line comment replaces just that one line, a multi-line one its whole range. Since a pending comment doesn't report its range (see step 2), read the anchor off `diff_hunk` — its last line is the anchored line. **A suggestion spanning more lines than the comment is anchored to produces broken code when applied**, and the anchor can't be changed over the API. If the user's own suggestion has that problem, keep it as they wrote it and tell them to re-anchor the comment on GitHub (delete + re-add as a multi-line selection) rather than silently trimming their code.

````
```suggestion
<replacement code for those exact lines>
```
````

If the user's own comment already contains a `suggestion` block, keep it and refine only the prose around it — don't rewrite their proposed code.

### 8. Ask for the general impression, then apply

The review-level summary body must be the **user's own words**, not your synthesis of their comments. Ask them (AskUserQuestion or plain prose) for a one-or-two-line general impression of the PR — unless the draft review already has a non-empty `body`, in which case refine *that* the same way as step 4 and pass it via `--impression`.

Write the refinements to a JSON file — only the comments whose text actually changed:

```json
[
  {"node_id": "PRRC_kwDO...", "body": "<refined body — plain prose, plus inline links (step 6) or a ```suggestion``` block (step 7) only where they earn their place>"},
  ...
]
```

Then preview and apply:

```bash
ruby ~/.claude/skills/refine-draft-review/scripts/draft_review.rb apply \
  --repo <owner>/<repo> --pr <number> --comments <path-to-json-file> --dry-run

ruby ~/.claude/skills/refine-draft-review/scripts/draft_review.rb apply \
  --repo <owner>/<repo> --pr <number> --comments <path-to-json-file> \
  --impression "<the user's own general take>"
```

Read the script's own header comment for the full behavior contract; the short version:

- **Never submits anything.** No code path in the script sets `event` — the review stays `PENDING`.
- **Edits in place, never deletes.** Each listed comment's body is rewritten via GraphQL `updatePullRequestReviewComment` (falling back to REST `PATCH /pulls/comments/{id}`); comments you don't list are untouched. Line anchors, threads, and ordering are preserved.
- **Skips no-ops** — a listed comment whose refined body equals the current one is left alone.
- **The summary-body limitation:** GitHub refuses to set a body on a pending review that *already has an empty body* (confirmed on both the REST and GraphQL update paths — no known workaround). A hand-started draft review usually *is* bodiless, so expect this to fail here more often than it does in `hunk-pr-comment`. When it does, the script prints the intended summary text instead of silently giving up — pass that text along to the user so they can paste it into GitHub's "Finish your review" dialog at submit time.

### 9. Report back

The script already prints which comments it rewrote plus the full post-edit state of the review and a closing "still a DRAFT" reminder — relay that rather than re-deriving it by hand. On top of what it printed, tell them:
- The PR's review URL (`gh pr view <number> --json url -q .url`, "Files changed" tab).
- Which comments you deliberately left untouched because they were already clean.
- Any `<...>` hint you couldn't fulfill, or duplicate comments they may want to delete themselves.
- If the script warned about the summary-body limitation, the exact text it printed, so they can paste it in themselves.
- That they must open it on GitHub and click "Submit review" themselves — this skill will never do that for them.

## Guidelines

- **These are drafts, not real comments.** Nothing becomes visible to other PR participants until the user reviews and submits the pending review themselves on GitHub. Treat "refine" as "tidy up for the user's own approval," not "publish."
- **Never submit the review.** No `event` parameter, ever, unless the user explicitly says to submit it in this same request. (The script has no code path for this at all — don't add one without the user asking.)
- **Never delete a comment**, even one you think is redundant or superseded. Flag it and let the user delete it on GitHub.
- **Always disclose AI involvement in the review body.** The summary body carries this disclaimer, verbatim, at the top: *"These are my own review notes, rewritten by AI for linguistic clarity and manually reviewed before posting."* If you pass `--body` to override it, keep the disclaimer — don't drop it.
- **Never invent feedback.** Only refine what's already in the draft review — don't add new review points from your own read of the diff. If you spot something genuinely worth raising, mention it to the user in chat and let them decide.
- **Don't over-edit.** The cleanup pass is spelling/grammar/trim only. If a comment is already clean, leave it exactly as it is.
- **Don't add redundant code quotes.** GitHub already shows diff context above every inline comment — never re-quote it. The only fenced code that belongs in a comment is a genuine ```suggestion``` diff (step 7), reserved for substantial, non-trivial changes.
- **Link, don't fabricate.** Internal links (step 6) must point at a symbol you actually located with `grep`; external links must point at a doc page you actually fetched and confirmed. No link beats a wrong or dead one.
- **Ask before applying** if more than a couple of comments are ambiguous about what they refer to, or if refining one would require changing its meaning to make it read correctly.
- Any script this skill ships must be Ruby (see global CLAUDE.md) — don't add a Python/bash script alongside or instead of `draft_review.rb`; extend it in place.
