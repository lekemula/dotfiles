---
name: create-jira-ticket
description: Create a Jira ticket with user story format, context, acceptance criteria, and test scenarios. Use when asked to create, write, or draft a Jira ticket or issue.
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, WebFetch
---

Create a Jira ticket based on `$ARGUMENTS` and any context from the current conversation.

## Arguments

Usage: `/create-jira-ticket [BOARD] [description]`

- **First argument** (`$0`): Jira board key (e.g., `LI`, `COBA`, `PLAT`). If not provided, ask the user which board before drafting.
- **Remaining arguments**: Description or context for the ticket.

## Steps

1. Parse `$ARGUMENTS`: extract the board key (first word, if it looks like a Jira key in uppercase) and the ticket description from the rest.

2. Gather required information from `$ARGUMENTS` and conversation context:
   - **Board**: Jira board key (e.g., `LI`)
   - **Persona**: who is this for? (e.g., "developer", "lender", "admin user")
   - **Action**: what do they want to do?
   - **Goal**: why? what outcome do they want?
   - **Context**: background, problem description, links to discussions or docs
   - **Acceptance Criteria**: concrete, testable requirements
   - **Test scenarios**: how to verify the feature works

3. If the board key or any required fields are missing or unclear, ask the user before drafting.

4. Read relevant code files if needed to understand the current implementation before writing acceptance criteria or test scenarios.

5. Draft the ticket using the format below.

## Output Format

Output the ticket in markdown so it's ready to paste into Jira:

---

**Board**: [BOARD KEY]
**Summary**: [One-line description of the ticket]

---

As a **[persona]** I would like to **[action]** in order to **[goal]**

### Context

[Describe the problem, include relevant background, links to discussions, docs, related tickets, or code references]

### Acceptance Criteria

1. [Requirement 1 — specific and testable]
2. [Requirement 2]
3. [Add more as needed]

### Test

[Describe how to manually test or verify the feature. Include steps, edge cases, and expected outcomes. Reference automated test coverage if applicable.]

---

## Guidelines

- Write acceptance criteria as concrete, verifiable statements (avoid vague terms like "should work correctly")
- Each AC item should be independently testable
- Test section should describe both happy path and edge cases
- Keep the user story format strict: "As a X I would like to Y in order to Z"
- If this is a bug ticket, adapt the format: replace the user story with a "**Bug**:" description and add **Steps to Reproduce** before acceptance criteria
