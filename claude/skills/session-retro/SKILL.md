---
name: session-retro
description: Review the current conversation for remarks the user made (corrections, preferences, decisions, conventions) and persist the durable ones to the right place — global CLAUDE.md, the project's CLAUDE.md, or auto-memory. Use when the user says things like "update CLAUDE.md", "save this to CLAUDE.md", "add this as a project rule", "session retro", or wants an end-of-session cleanup of instructions.
---

# Update CLAUDE.md

Deliberate, user-confirmed counterpart to the passive auto-memory system. Auto-memory
already listens for corrections/facts turn-by-turn; this skill instead does a batch
pass over the conversation on demand and writes to CLAUDE.md files too, not just memory.

## Workflow

1. **Scan the conversation** for candidate remarks: explicit corrections ("no, don't...",
   "stop doing X", "always..."), explicit asks ("add this to CLAUDE.md", "remember that..."),
   and decisions/conventions stated in passing. Ignore anything already reflected verbatim
   in an existing CLAUDE.md or memory file.

2. **Classify each candidate's destination:**

   | Destination | When |
   |---|---|
   | `~/.claude/CLAUDE.md` (global) | Standing behavior/preference that applies regardless of project (tone, git workflow, tool habits, general coding style). |
   | Project `CLAUDE.md` (repo root, or nearest ancestor to cwd) | Standing convention specific to *this* codebase (stack choices, test/lint commands, architecture rules, "always use X here"). |
   | Auto-memory (`~/.claude/projects/<slug>/memory/`) | Anything that fits the existing `user`/`feedback`/`project`/`reference` memory types — see the memory instructions already loaded in context. Prefer this for facts that can go stale (deadlines, who's doing what, external pointers) rather than durable standing instructions. |

   If a remark could fit both a project CLAUDE.md and memory, prefer CLAUDE.md only when
   it's a rule you'd want followed unconditionally on every future task in that repo;
   otherwise defer to memory's own type rules (don't duplicate memory's job).

3. **Present a summary before writing anything.** Group proposed changes by destination
   file, show the exact line(s) to add/change (like a mini diff), and skip presenting
   remarks you decided NOT to persist only if it's obvious why — otherwise list them too
   with a one-line reason, so the user can override.

4. **Wait for explicit confirmation.** Let the user approve all, approve a subset, edit
   wording, or reject. Never write CLAUDE.md changes silently — these are shared,
   high-leverage files unlike routine memory writes.

5. **Apply only approved edits:**
   - CLAUDE.md: merge into the most fitting existing section (create one only if none
     fits); match the file's existing style (short imperative bullets); don't restate
     something already covered.
   - Memory: follow the standard memory-writing steps already defined for this session
     (frontmatter file + `MEMORY.md` index pointer) — don't hand-roll a different format.

6. **If no project CLAUDE.md exists** for the current repo, ask whether to create one
   (pointing at the `init` skill/command) before writing project-scope edits there.

## Notes

- This is invoked on demand, not automatically — don't trigger it just because a
  correction happened; wait for the user to ask (directly, or via an end-of-session
  wrap-up request).
- In the dotfiles repo, `claude/CLAUDE.md` and `claude/skills/` are symlinked wholesale
  into `~/.claude/`, so edits there take effect immediately with no extra install step.
- Keep entries concise — one bullet per rule/fact, no rationale essays inline (save the
  "why" for memory entries, which have a dedicated field for it).
