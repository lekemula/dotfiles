---
name: hunk-address-comments
description: Read the review notes left in a live Hunk session (the `c` notes from the hunk TUI) and actually fix the code they ask for — then run the repo's own tests and reply in-session with what changed. Use when asked to address, fix, apply, or resolve hunk notes / hunk comments / review feedback from a running Hunk session.
disable-model-invocation: false
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

# Hunk: address review comments

Take the notes the user left on a live Hunk session and **change the code** to satisfy them. Then
verify with the repo's own tests, and leave one reply note per resolved item so the user sees the
outcome in the TUI where they wrote the feedback.

Hunk's TUI belongs to the user. Never run `hunk diff`, `hunk show`, or any other interactive
command — drive the live session through `hunk session *` only.

Related skills, so you pick the right one:

| Skill | Does |
|---|---|
| `hunk-review` | Narrates a diff for the user — navigate and explain, no code changes |
| `hunk-pr-comment` | Exports the user's notes to GitHub as a pending PR review |
| **this one** | Turns the user's notes into committed-quality code changes |

## Workflow

```text
1. hunk session list                                        # find the session; note its id
2. hunk session comment list <id> --type user --json        # READ THE NOTES  (see step 2 — --type user is mandatory)
3. read each referenced file at the referenced line         # understand the note against real code
4. fix the code                                             # the substance, not the letter
5. run the repo's tests + linter                            # whatever this repo actually uses
6. hunk session reload <id> -- diff                         # re-sync; your edits moved the lines
7. hunk session navigate <id> --file <p> --new-line <n>     # steer the user's view
8. hunk session comment add <id> ... --author claude        # one reply per resolved note
9. report: note -> change -> verification
```

### 1. Select the session

`hunk session list` prints each session's id, path, repo and **comment count**. Prefer the explicit
`<session-id>` over `--repo` from the start: several sessions often share one repo (especially with
worktrees), and `--repo` then fails with *"Multiple active sessions match"*. When more than one
matches, the right one is normally the session whose comment count is non-zero.

If no session exists, ask the user to launch Hunk — do not guess at the diff from `git`.

### 2. Read the notes — `--type user` is mandatory

```bash
hunk session comment list <session-id> --type user --json
```

**Without `--type user` you get the legacy live-agent view and will see none of the human's notes**,
which reads exactly like "there are no comments". This is the single easiest way to get this task
wrong. Human notes come back with `"source": "user"` and ids like `user:1787…`; notes you add later
appear as `mcp:…`.

Each note carries `noteId` (`user:…` for the human's, `mcp:…` for ones you add), `source`,
`filePath`, `hunkIndex`, `newRange` / `oldRange`, and `body`.

`hunk session review <id> --json` gives the file and hunk structure plus `reviewNoteCount`; add
`--include-notes` to get both in one call. Use `--include-patch` only when you genuinely need raw
diff text. **Everything is nested under a top-level `review` key** — there is no root-level `files`,
so parsing for one silently yields nothing.

### 3. Understand before changing

Read the actual file at the referenced line. Note bodies are terse — written mid-review, in the
user's shorthand — and the line number is where the cursor was, which is not always where the fix
belongs.

**Address the substance, not the letter.** A short note often points at a deeper defect than it
literally names. Example: *"Use match with a hash"* on `expect(response.parsed_body).to
eq(SomeClass.thing)` is nominally about a matcher, but the real problem is that the assertion
compares the response against the very method the code under test calls — it passes even when the
behaviour is wrong. Applying the matcher without fixing the tautology satisfies the words and misses
the point. Fix the underlying issue and say so in the reply.

Equally, don't inflate: if honouring a note implies a refactor well beyond it, make the change the
note asks for and flag the rest in your report rather than doing it unasked.

Some notes are questions, not change requests. Answer those in a reply note; don't edit code to
"resolve" a question.

If a note is ambiguous enough that two readings produce materially different code, ask the user
before writing it.

### 4. Verify

Run what this repo actually uses — discover it, don't assume. Run the focused test first, then the
full suite plus linter, so you can report that nothing else regressed. If a change removes a now
redundant test, say so explicitly; a dropped example otherwise looks like an accident.

### 5. Reload before replying

Your edits shift line numbers, so the session's content is stale:

```bash
hunk session reload <session-id> -- diff
```

Recompute target lines from the file as it is **now** — reusing the note's original `newLine` will
land your reply on the wrong line. Reload also matters when your fix added or removed lines above
the note.

### 6. Reply in-session

One reply per resolved note, anchored to the changed line:

```bash
hunk session comment add <session-id> \
  --file <path> --new-line <n> --author claude \
  --summary "Done: <what changed, one sentence>" \
  --rationale "<why, and anything the user should know — a deeper issue found, a test removed, a rejected reading>"
```

- `--summary` is a real sentence; it is the fallback text and what `comment list` shows.
- Use `comment apply --stdin` when several notes are resolved at once — it validates the whole batch
  before mutating the session — and `comment add` for a single note.
- `--focus` on the one note the user should look at first; not on every note.
- Quote `--summary` and `--rationale` defensively in the shell.
- **Never delete or edit the user's notes.** `comment rm` / `comment clear` are for notes you added.
  Resolution is recorded by replying, not by erasing the request.

### 7. Report

Per note: what it asked, what changed, and how it was verified. Call out any note you did not act on
and why — a question you answered, a reading you rejected, something needing the user's decision.

## Rules

- Change code; a reply note alone does not address a note.
- Never run `hunk diff` / `hunk show`.
- Don't touch the user's notes.
- Don't commit or push unless the user asks.
- Stay inside the notes' scope; report adjacent problems instead of fixing them silently.

## Common errors

- **"Multiple active sessions match repoRoot …"** — pass `<session-id>`. The listing names the ids.
- **No notes returned** — you almost certainly omitted `--type user` (see step 2).
- **"No diff file matches …"** — the file is not in the loaded review; check `hunk session context`,
  then `reload`.
- **"No active Hunk sessions"** — if Hunk is visibly running, localhost may be blocked by the agent
  sandbox; retry with escalation. Otherwise ask the user to open Hunk.
- **"Specify exactly one comment target: --old-line <n> or --new-line <n>."** — pass exactly one of
  the two. The `comment apply` batch validator has its own wording: *"Comment N must specify exactly
  one of `hunk`, `hunkNumber`, `oldLine`, or `newLine`"* — batch items also each require `filePath`
  and `summary`.
- **Reply lands on the wrong line** — you skipped the reload in step 5.
