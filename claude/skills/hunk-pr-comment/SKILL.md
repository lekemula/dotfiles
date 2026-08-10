---
name: hunk-pr-comment
description: Turn your local Hunk review notes (the `c` notes left while reviewing a diff in the hunk TUI) into a draft/pending GitHub PR review — cleans up typos and phrasing minimally, adds a real `suggestion` diff only where one genuinely helps, then posts as an unsubmitted pending review for the user to finalize. Use when asked to post, publish, sync, or turn hunk notes/comments into a PR review or draft review.
disable-model-invocation: false
allowed-tools: Bash, Read, AskUserQuestion
---

Take the user's current Hunk review notes for a local diff and post them as a **pending (draft, unsubmitted)** review on a GitHub pull request, lightly cleaned up. Comments are plain prose by default — GitHub's own diff view already supplies code context, so don't re-quote it (see step 6).

The actual posting logic lives in `scripts/post_review.rb` (Ruby, next to this file) — read it before your first run of this skill so you know what it does; steps 9-10 below just describe how to drive it.

## Arguments

Usage: `/hunk-pr-comment $ARGUMENTS` where `$ARGUMENTS` is a PR URL or number. Examples:

- `/hunk-pr-comment 282`
- `/hunk-pr-comment https://github.com/LoanLink/ehyp-integrations/pull/282`
- `/hunk-pr-comment LoanLink/ehyp-integrations#282`

If no argument is given, try `gh pr view --json number,url` for the current branch; if that fails, ask which PR.

## Steps

### 1. Resolve the PR and repo

Parse `$ARGUMENTS` for `owner/repo` and PR number. If only a number is given, use the current repo (`gh repo view --json nameWithOwner -q .nameWithOwner`).

```bash
gh pr view <number> --repo <owner>/<repo> --json number,url,headRefName,headRefOid,baseRefName
```

### 2. Fetch the live Hunk notes

```bash
hunk session comment list --repo . --type user --json
```

- If this errors (no live session), tell the user to open the diff in Hunk first (`hunk diff` in another terminal) and stop.
- If `comments` is empty, tell the user there's nothing to post and stop.
- Each note has: `noteId`, `filePath`, `hunkIndex`, `newRange` (`[startLine, endLine]` on the new side, or `oldRange` for notes anchored on deleted lines), `body`, `author`, `createdAt`.

### 3. Verify the local checkout matches the PR head

Line numbers only carry over correctly if the local diff Hunk is reviewing *is* the PR's diff.

```bash
git rev-parse HEAD
git status --porcelain
```

- If `HEAD` doesn't match `headRefOid` from step 1, warn the user their local commit differs from the PR head and ask whether to continue (line numbers may be off) or abort.
- If the working tree is dirty, warn similarly.
- Also worth a sanity check when the PR number was hand-typed: confirm the files the notes are actually anchored to exist on the PR's branch (`git ls-tree -r origin/<headRefName> --name-only | grep <file>`). A PR number typo or a mismatched competing-PR situation (seen in practice: two alternative PRs implementing the same ticket) produces exactly this kind of mismatch, and posting anyway either fails outright or attaches nonsense.

### 4. Group notes by file + line

Multiple notes can land on the same line (seen in practice — e.g. two notes both on `mapping_tools.rb:6`). Merge notes that share the same `filePath` + line range into **one** GitHub comment (as separate short paragraphs), rather than posting duplicate comments on the same line.

### 5. Clean up each note's text

For each (merged) note, do a **light, minimalistic edit pass** — not a rewrite:

- Fix typos and obvious grammar slips (e.g. "seet" → "set", "thuoght" → "thought", "leggit" → "legit").
- Trim filler, but preserve the reviewer's actual wording, tone, and intent as closely as possible.
- Keep nits as nits, questions as questions, suggestions as suggestions — do not upgrade a casual "what's the idea behind this?" into a formal demand.
- Do **not** add new claims, soften/harden the feedback, or merge distinct points into a vaguer one.
- **Watch for `<...>` placeholder hints** — a reviewer sometimes leaves themselves a bracketed note-to-self mid-comment, e.g. `<add a code example>`, `<link this>`, `<expand on why>`. Treat that as an instruction to actually fulfill before posting, not text to clean up around: write the code example, add the link (step 7), or expand the point as directed. Once fulfilled, remove the `<...>` marker itself — it should never appear literally in the posted comment. If you can't confidently fulfill a hint (e.g. `<add a code example>` but no unambiguous example is inferable from the note), say so when reporting back and leave the placeholder text out rather than posting a bracketed TODO to GitHub.

### 6. Do NOT add plain "context" code quotes

Learned the hard way: GitHub's inline review UI *already* shows the diff hunk (several lines of surrounding context, colored) directly above every inline comment. A fenced ```ruby block that just re-quotes the current code — with no actual change — is pure redundancy the reviewer has to scroll past, and it's *especially* pointless on wholly-new files (the entire file is green/new in the diff already, so quoting any of it back adds nothing).

**Rule: never add a plain quoted-code block "for context."** If a note genuinely needs more surrounding code than GitHub's diff view shows (e.g. it references a line 40 rows away from the anchor), say so in prose ("...as used again in `other_method` a few lines below") or link to it (step 7). Only fenced code that belongs in a comment is a real `suggestion` block — see step 8.

### 7. Link code references instead of quoting them

When a note mentions a specific symbol — a class, method, module, constant — link it rather than pasting its source (pasting would be exactly the redundant quoting step 6 just banned):

- **Internal references** (something defined in this repo): link to its exact GitHub location using a permalink built from the PR's `headRefOid` (the commit SHA from step 1, not the branch name — branches move, commits don't):
  `https://github.com/<owner>/<repo>/blob/<headRefOid>/<path-to-file>#L<line>`
  Find the real line first — `grep -n 'def method_name\|class Name\|MODULE_NAME =' <file>` — never guess a line number. Link the bare file (no `#L`) when the reference is to the whole file/class rather than one specific spot.
- **External / third-party references** (a Rails method, a gem, a language feature — e.g. "Rails' error object," "Rails associations"): link to its official documentation instead — `api.rubyonrails.org` for ActiveModel/ActiveRecord/etc. classes, `guides.rubyonrails.org` for conceptual guides, `ruby-doc.org` for core Ruby, or the gem's own README/rubydoc.info page for anything else. Fetch the target page first to confirm it actually exists and covers what the note means — never fabricate a doc URL from a guessed naming convention.
- Link inline in the prose (`` Rails' [`ActiveModel::Errors`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html) ``) — one link per reference, not a "References:" footer section.
- If you're not confident a reference resolves cleanly (an ambiguous term, a symbol you can't actually find under that name), skip the link rather than post a wrong or dead one. A missing link is harmless; a broken one looks careless.

### 8. Consider a suggestion block — only for real, non-trivial diffs

Only add a ` ```suggestion ` fenced block (GitHub's inline-fix format) when:

- The note proposes a **concrete, unambiguous** code change (a rename, an extracted constant, a small restructuring where the resulting code is inferable), **and**
- It's an actual **diff** — the suggested replacement must differ from the current code. Never post a `suggestion` block whose content is identical (or trivially/cosmetically different, e.g. only whitespace) to what's already there.
- It's **not trivial** — a one-word rename buried in a large block, or a change so small the prose comment already conveys it fully, doesn't need a suggestion block on top. Reserve suggestions for changes substantial enough that seeing the actual replacement code saves the reviewer real effort.
- You can write the replacement for the exact line range without guessing at intent not stated in the note, **and**
- The replacement is self-contained to that single anchored line — if making the change correctly requires editing other lines too (e.g. renaming a variable used again a few lines down), a one-line suggestion block would produce broken code. Skip it and leave a plain comment instead.

If the note is a question, a design objection, or a suggestion too open-ended to render as literal replacement code (e.g. "this deserves its own class"), do **not** fabricate a suggestion block — leave it as a plain comment. Never invent code the user didn't ask for.

In practice, most comments should end up as **plain prose, no fenced code at all**. A suggestion block is the exception, not the default.

A suggestion block replaces the exact `newRange` lines it's commented on:

````
```suggestion
<replacement code for those exact lines>
```
````

### 9. Build the comments file and run the script

Write the grouped, cleaned-up, link-enriched comments (steps 4-8) to a JSON file:

```json
[
  {"path": "<filePath>", "line": <endLine>, "side": "RIGHT", "body": "<cleaned body — plain prose, plus inline links (step 7) or a ```suggestion``` block (step 8) only where they earn their place>"},
  ...
]
```

- `side` is `"RIGHT"` for `newRange`-anchored notes, `"LEFT"` for `oldRange`-anchored ones.
- For multi-line notes, this script only takes a single `line` per comment (no `start_line`) — anchor on the last line of the range; that's a real limitation, not a bug, so mention it to the user if a note spans several lines and the anchor feels imprecise.

Then run:

```bash
ruby ~/.claude/skills/hunk-pr-comment/scripts/post_review.rb \
  --repo <owner>/<repo> --pr <number> --commit <headRefOid> --comments <path-to-json-file>
```

Consider `--dry-run` first if you or the user want a final look at what would be posted before it touches GitHub. Read the script's own header comment for the full behavior contract; the short version:

- **Never submits anything.** No code path in the script sets `event` — everything it creates or appends to stays `PENDING`.
- **No duplicate reviews.** If the user already has a pending review on this PR (started by hand on GitHub, or left over from an earlier run), the script detects it and appends the new comments to *that same* review via GraphQL (`addPullRequestReviewThread`) instead of failing on GitHub's "one pending review per user" rule. Existing comments on that review are never touched.
- **Auto-generates a summary body** (grouped by file, one-line gist per comment) prefixed with a disclaimer (see Guidelines) — unless you pass `--body` to override it entirely. This is the review's top-level comment, distinct from the per-line inline comments.
- **The summary-body limitation:** GitHub refuses to set a body on a pending review that *already has an empty body* (confirmed on both the REST and GraphQL update paths — there's no known workaround). This only bites when appending to a review that predates this script (e.g. started by hand with no summary typed in). When that happens the script prints the intended summary text instead of silently giving up — pass that text along to the user so they can paste it into GitHub's "Finish your review" dialog themselves at submit time.

### 10. Report back

The script already prints a per-comment summary (path:line + gist) and a closing "still a DRAFT" reminder — relay that to the user rather than re-deriving it by hand. On top of what it printed, tell them:
- The PR's review URL (`gh pr view <number> --json url -q .url`, "Files changed" tab).
- If the script warned about the summary-body limitation, the exact text it printed, so they can paste it in themselves.
- That they must open it on GitHub and click "Submit review" themselves — this skill will never do that for them.

## Guidelines

- **These are drafts, not real comments.** The entire point of this skill is that nothing becomes visible to other PR participants until the user reviews and submits the pending review themselves on GitHub. Treat "post" as "stage for the user's own approval," not "publish."
- **Never submit the review.** No `event` parameter, ever, unless the user explicitly says to submit it in this same request. (The script has no code path for this at all — don't add one without the user asking.)
- **Always disclose AI involvement in the review body.** The auto-generated summary body always carries this disclaimer, verbatim, at the top: *"These are my own review notes, rewritten by AI for linguistic clarity and manually reviewed before posting."* If you pass `--body` to override the summary for some reason, keep this disclaimer in it — don't drop it.
- **Never invent feedback.** Only post what's in the user's Hunk notes, cleaned up — don't add new review points from your own read of the diff.
- **Don't over-edit.** The cleanup pass is spelling/grammar/trim only. If a note is already clean, post it verbatim.
- **Don't add redundant code quotes.** GitHub already shows diff context above every inline comment — never re-quote it. The only fenced code that belongs in a comment is a genuine ```suggestion``` diff (step 8), and even those should be reserved for substantial, non-trivial changes.
- **Link, don't fabricate.** Internal links (step 7) must point at a symbol you actually located with `grep`; external links must point at a doc page you actually fetched and confirmed. No link beats a wrong or dead one.
- **Ask before posting** if the local checkout doesn't match the PR head, the PR number seems inconsistent with what the notes are actually about, or more than a couple of notes are ambiguous about which line they anchor to.
- After a successful post, do **not** delete the Hunk notes automatically — leave that to the user (`hunk session comment clear --repo . --include-user --yes` if they want to clear them afterward).
- Any script this skill ships must be Ruby (see global CLAUDE.md) — don't add a Python/bash script alongside or instead of `post_review.rb`; extend it in place.
