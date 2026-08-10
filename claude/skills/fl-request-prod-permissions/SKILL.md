---
name: request-prod-permissions
description: Request temporary FinLink/Coba production access by cloning PERM-1 on the Jira PERM board. Use when asked to request prod access, production permissions, or open a PERM ticket.
disable-model-invocation: false
allowed-tools: AskUserQuestion, Bash
---

Clone the `PERM-1` template on the FinLink Jira `PERM` board (https://finlink.atlassian.net/jira/software/c/projects/PERM/boards/96) to request temporary production access.

## Arguments

Usage: `/request-prod-permissions <ticket-or-reason> <days>`

- **First arg**: either a Jira key (e.g. `LI-1234`, `COBA-42`) for linked context, or a free-text reason in quotes.
- **Second arg**: duration in days (integer).

Examples:
- `/request-prod-permissions PERM-1 3`
- `/request-prod-permissions "debugging payment webhook" 5`

If `$ARGUMENTS` is empty or malformed, ask the user for both values before proceeding.

## Steps

1. **Parse `$ARGUMENTS`**: split into `<first>` and `<days>`. Validate that `<days>` is a positive integer; reprompt if not.

2. **Classify first arg**: if it matches `^[A-Z]+-\d+$`, treat it as a linked Jira ticket. Otherwise treat it as the free-text reason.

3. **Resolve dates at run-time** via Bash (do NOT rely on any `currentDate` context — it may be stale):
   ```
   start=$(date +%d.%m.%Y)
   end=$(date -v+${days}d +%d.%m.%Y)
   ```
   Use these as `<start>` and `<end>`.

4. **Fetch the template** with `mcp__claude_ai_Atlassian__getJiraIssue`:
   - `cloudId`: `finlink.atlassian.net`
   - `issueIdOrKey`: `PERM-1`
   - `responseContentFormat`: `markdown`

   Use this to confirm issue type and table shape.

5. **If first arg was a Jira key**: fetch that ticket the same way and extract its summary. Set:
   ```
   Why? = "Linked to <KEY>: <summary>"
   ```
   Otherwise set `Why? = <free-text reason>`.

6. **Ask for missing fields** in a single batched `AskUserQuestion` call (skip any already inferable):
   - **Environment** (pick ONE — **never both**, this is a hard rule from DevOps; if access to both is needed, run the skill twice for two separate tickets):
     - `FinLink` — options offered for System: `Azure Finlink Production`, `Observability Finlink Production`, or `Azure Finlink Production, Observability Finlink Production`.
     - `CoBa` — options offered for System: `Coba Production`, `Observability Coba Production`, or `Coba Production, Observability Coba Production`.
   - **Role** — default option: `Reader`. Offer `Writer` and `Admin`.
   - **What** — default option: `Access to observability and production database`.

7. **Build the summary** (ticket title):
   ```
   Lekë Mula requires <System> Production Access
   ```

8. **Build the description** as markdown, matching `PERM-1` exactly:
   ```
   ## Please ensure that:
   ## 1. The title states the name of the person that needs the access, and
   ## 2. The duration is in the format DD.MM.YYYY - DD.MM.YYYY

   | **Who?** | **Lekë Mula** |
   | --- | --- |
   | Why? | <reason> |
   | What? | <what> |
   | System | <system> |
   | Role | <role> |
   | Duration | <start> - <end> |
   ```

9. **Preview + confirm**: print the summary and rendered table to the user, then `AskUserQuestion` with options:
   - **Create the ticket** (default)
   - **Edit a field** — if chosen, ask which field, update, re-preview
   - **Cancel**

10. **Create the ticket** with `mcp__claude_ai_Atlassian__createJiraIssue`:
    - `cloudId`: `finlink.atlassian.net`
    - `projectKey`: `PERM`
    - `issueTypeName`: `Story`
    - `summary`: the title from step 7
    - `description`: the markdown from step 8

11. **Output** the new ticket URL: `https://finlink.atlassian.net/browse/<NEW-KEY>`.

12. **Post to #devops Slack** to nudge the team:
    - Resolve the channel id via `mcp__claude_ai_Slack__slack_search_channels` (query `devops`).
    - **Ping Rami directly** (not the usergroup). Resolve his Slack user ID via `mcp__claude_ai_Slack__slack_search_users` (query: `Rami`) and use `<@USERID>` mention syntax so he gets pinged. If the lookup returns no results, fall back to plain `@Rami` text. Known ID: Rami = `U02NUT30RRD`.
    - **Do not tag the DevOps usergroup.** The word "DevOps" appears in the message as a plain string only — no `<!subteam^...>`, no `@devops-team`.
    - Draft the message in this fixed shape — keep it polite, brief, slightly funny but **not too creative**. Vary only one phrase per call so consecutive requests don't look identical. **Always include the full ticket URL** (not just the bare key) so the link is clickable even if Slack's Jira app doesn't auto-unfurl, and so the message stays correct without needing a later edit (the Slack MCP server exposes no `chat.update`):
      ```
      Hi <@RAMI_ID> (or DevOps), https://finlink.atlassian.net/browse/<NEW-KEY> — I require some access to Finlink production. <closer>
      ```
      where `<closer>` rotates among short polite sign-offs, e.g.:
      - `Thank you so much beforehand!`
      - `Thanks a million in advance 🙏`
      - `Many thanks in advance!`
      - `Thanks a lot, you're the best!`
      - `Appreciate it, team 🙌`
    - Show the drafted message to the user and `AskUserQuestion`: **Send** / **Rewrite** / **Skip**.
    - On Send: call `mcp__claude_ai_Slack__slack_send_message` with the resolved channel id and the message text. Output the resulting Slack permalink.

## Notes

- Requester is always Lekë Mula — do not ask for the name.
- **One environment per ticket — never both.** Each PERM ticket must request access to either FinLink **or** CoBa, not both. DevOps will reject mixed tickets and ask you to split. If the user explicitly asks for both in a single invocation, ABORT before creating and tell them to run the skill twice (once per environment). Validate the assembled `System` value before submitting: it must NOT contain both `Finlink` and `Coba` (case-insensitive).
- Do not set assignee; PERM-1 is unassigned, the permissions team picks it up from the board.
- Never invent a Jira key if the user gave a reason that happens to start with capital letters but isn't a real ticket — the regex `^[A-Z]+-\d+$` is the only signal.
- If `createJiraIssue` fails, surface the error verbatim — do not retry with altered fields.
