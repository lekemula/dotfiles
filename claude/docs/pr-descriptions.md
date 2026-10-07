# PR descriptions

Keep them compact. Reference: https://github.com/LoanLink/ehyp-integrations/pull/315 — roughly 1.8KB including two screenshots. A description orients a reviewer; it is not the record. Evidence, root-cause analysis and the reasoning behind a decision live on the ticket or a Confluence page and get *linked* from the PR, never restated in it.

The description covers the high-level approach only. Anything that explains a particular hunk goes as an inline comment on that line of the diff — not in the description, and not as a code comment.

Follow the repo's `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`) when one exists — it wins over the shape below.

With no template, use these sections and omit any that don't apply:
- `### Ticket` — Jira ticket link, or the `NO-REF` branch prefix. Omit the section entirely if neither applies.
- `### Purpose` — why, in a line or two.
- `### Approach` — a few one-line bullets summarizing the change. High-level components only, never a file-by-file walkthrough. Order the bullets the way a reviewer should read the PR.
- `### Review notes` — only to say the PR is best reviewed commit-by-commit, when the commits are atomic. Omit otherwise.
- `### Testing` — high-level user interface steps if applicable; `rake` task snippets for prerequisites or when the PR changes local dev tooling; related end-to-end tests added in other PRs/repos (e.g. `loanlink-web`). Never mention that unit tests pass — that is a given.

Show, don't explain — a screenshot or a before/after payload speaks a million words. Proof is the part that earns its space: lead with it and delete the prose it makes redundant. Screenshots and evidence always stay; the paragraphs around them are what gets cut.

Cut on sight: narrative walkthroughs, speculative caveat lists, "future improvements" sections, file-by-file summaries, and collapsed `<details>` blocks — a before/after belongs inline as a couple of lines of code or JSON.
