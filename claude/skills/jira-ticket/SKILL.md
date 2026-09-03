---
name: jira-ticket
description: Write a Jira ticket — create a new one, or update an existing one's summary, description, context, acceptance criteria, or test section — in user-story format, splitting raw investigation detail into a follow-up comment. Use whenever asked to create, write, draft, file, update, edit, revise, reword, expand, or reformat a Jira ticket or issue, or to change what a ticket says.
disable-model-invocation: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
  - mcp__claude_ai_Atlassian__getVisibleJiraProjects
  - mcp__claude_ai_Atlassian__getJiraProjectIssueTypesMetadata
  - mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian__createJiraIssue
  - mcp__claude_ai_Atlassian__editJiraIssue
  - mcp__claude_ai_Atlassian__addCommentToJiraIssue
  - mcp__claude_ai_Atlassian__getJiraIssue
---

<!-- JIRA_TICKET_SKILL_ACTIVE — sentinel read by the claude-jira-skill-gate hook; do not remove. -->

Write Jira ticket content — new or existing — based on `$ARGUMENTS` and the current conversation.

Keep the ticket readable but not bloated. The description carries the user story, the
`Context` a reader needs to understand the problem, the `Acceptance Criteria`, and a
`Test` section saying how to verify it. Raw investigation output — root-cause analysis,
repro logs, stack traces, file/line references — goes into a separate follow-up comment,
not the description.

## When this skill applies

Any time ticket *content* is written or rewritten, whichever tool ends up doing it:

- Creating a ticket (`createJiraIssue`).
- Editing an existing ticket's `summary` or `description` (`editJiraIssue`) — including
  "add acceptance criteria to LI-123", "tidy up that ticket", "add the findings to the
  ticket", "reword the description".
- Turning conversation findings into ticket text at all.

It does **not** apply to field-only changes that carry no prose: assignee, labels, sprint,
story points, status transitions, or a plain conversational comment.

## Arguments

Usage: `/jira-ticket [BOARD | ISSUE-KEY] [description]`

- **First argument** (`$0`):
  - a board key (e.g. `LI`, `COBA`, `PLAT`) → create a new ticket on that board;
  - an issue key (e.g. `LI-1234`) → update that existing ticket;
  - absent → infer from the conversation, and ask if it is still unclear.
- **Remaining arguments**: description, or the change being asked for.

## Steps — creating a new ticket

1. Parse `$ARGUMENTS`: board key (first word, if it looks like an uppercase Jira key) plus
   the ticket description from the rest.

2. Gather from `$ARGUMENTS` and conversation context:
   - **Board**: Jira board key (e.g., `LI`)
   - **Summary**: one line, imperative
   - **Persona / Action / Goal**: who it's for, what they want to do, and why — for a bug, the symptom and how it surfaced instead
   - **Context**: the background a reader needs to understand *why* this ticket exists — the problem, prior decisions, links to discussions, docs, or related tickets
   - **Acceptance Criteria**: concrete, verifiable requirements
   - **Test**: how to verify it works — steps, edge cases, expected outcomes, and any automated coverage that applies
   - **Supporting detail** (for the follow-up comment, not the description): root-cause analysis, logs, stack traces, affected files and line numbers

3. If the board key or the acceptance criteria are unclear, ask the user before drafting. Don't invent acceptance criteria.

4. Read relevant code files if needed to write accurate acceptance criteria and test steps. Keep raw findings (line numbers, log excerpts) in the follow-up comment — `Context` explains the problem, it doesn't dump the investigation.

5. Draft using the format below and show the draft to the user.

6. Before creating anything, check for an existing duplicate with
   `searchJiraIssuesUsingJql` on the board (e.g. `project = LI AND text ~ "<key phrase>"
   ORDER BY created DESC`). Surface any near-match and let the user decide.

7. **Wait for the user to approve the draft.** Filing a ticket is outward-facing and
   visible to the team — never create one without explicit confirmation, even if the
   user's original request sounded like "just make it".

8. On approval, create it:
   - Resolve `cloudId` with `getAccessibleAtlassianResources`.
   - Confirm the board key and pick a valid issue type with `getVisibleJiraProjects` and
     `getJiraProjectIssueTypesMetadata` — issue-type names vary per project, so don't
     assume `Bug` or `Story` exists.
   - Create the issue with `createJiraIssue`, passing the summary and the description
     (user story, `Context`, `Acceptance Criteria`, `Test`).
   - If there is raw investigation detail, post it with `addCommentToJiraIssue` as a
     **separate call** after the issue exists — never fold it into the description to
     save a call.

9. Report the created issue key and URL back to the user.

## Steps — updating an existing ticket

1. Resolve `cloudId` with `getAccessibleAtlassianResources`, then read the current ticket
   with `getJiraIssue` (summary + description). **Never write a description you haven't
   read first** — an `editJiraIssue` on `description` replaces the whole field, so an
   unread ticket means silently deleting whatever was there.

2. Map the existing description onto the format below. If it predates this format, keep
   every fact it carries and re-slot it into `Context` / `Acceptance Criteria` / `Test`;
   if something genuinely has no home, say so rather than dropping it.

3. Apply the requested change and re-check the whole description against the Guidelines —
   an update is the moment to fix a stale user story or a `Context` full of stack traces,
   not just to bolt on a new section.

4. Investigation detail stays out of the description on updates too: new logs, root cause,
   `file.rb:42` references go to `addCommentToJiraIssue`, even when the user says "add
   this to the ticket".

5. Show the user what changes — the full new description, and a short list of what is
   added, rewritten, or moved to a comment. **Wait for approval.**

6. On approval, call `editJiraIssue` with only the fields that change (typically
   `description`, sometimes `summary`). Don't touch fields the user didn't ask about.

7. Report the issue key and URL, and say what was changed.

## Output Format

Draft in this shape, then create or update it via the Atlassian tools once approved.

---

**Board**: [BOARD KEY]  (or **Ticket**: [ISSUE-KEY] when updating)
**Summary**: [one line, imperative]

As a **[persona]** I would like to **[action]** in order to **[goal]**

[For a bug, replace the user story with **Bug**: the symptom and how it was found, and add
a **Steps to Reproduce** list before Acceptance Criteria.]

### Context

[The background needed to understand why this ticket exists — the problem, prior
decisions, links to discussions, docs, or related tickets. A few sentences to a short
paragraph, not an investigation log.]

### Acceptance Criteria

1. [Specific and independently verifiable]
2. [Requirement 2]

### Test

[How to verify it works: steps, edge cases, and expected outcomes. Note any automated
coverage that applies.]

---

Then, only if there is genuine supporting detail, keep it separate under a clear heading —
this becomes a distinct `addCommentToJiraIssue` call, not part of the description:

---

**Posted as a comment on the ticket:**

[Root cause, repro logs, stack traces, `file.rb:42` references, investigation notes,
links to related tickets or discussions.]

---

If there is no such detail, omit the comment block entirely — don't pad it.

## Guidelines

- Write each acceptance criterion as an independently verifiable statement.
- Avoid vague terms like "should work correctly" — state the observable outcome.
- `Test` describes how a human verifies the change — happy path plus edge cases. It complements the acceptance criteria rather than restating them.
- Keep the user story format strict: "As a X I would like to Y in order to Z".
- Bug tickets: lead with the symptom, not the diagnosis. The diagnosis belongs in the comment.
- Keep `Context` free of log excerpts and `file.rb:42` references — those go in the comment.
- Summary is a title, so expand acronyms there (see the acronym rule in `~/.claude/CLAUDE.md`). In the comment body, expand on first use — e.g. `ExternalCreditDecision (ECD)` — then reuse the short form.
- One board per ticket. If the work spans both FinLink and Coba, that is two tickets.
- Never create or edit the issue before the user approves the draft.
- Keep tickets compact: a brief description (the symptom + how it was found) plus Acceptance Criteria. Move deep root-cause investigation, repro logs, and file/line detail into a comment, not the description.
