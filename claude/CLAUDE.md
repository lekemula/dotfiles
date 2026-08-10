# Global Preferences

## General
- Be concise. Skip obvious explanations.
- Don't add method comments unnecessarily. Only add comments for non-obvious code.
- Run tests/specs/linters after making changes to ensure nothing is broken.
- Don't commit or push unless I ask.
- Avoid unexpanded acronyms (ECD, LoA, etc.) in titles, headings, commit subjects, and PR/ticket titles. In long-form bodies, expand on first use — e.g. `ExternalCreditDecision (ECD)` — then reuse the short form. Code identifiers like `PROCESS_STATUS_ERROR` are not acronyms; use them as-is.

## Skills
- Any helper script bundled inside a skill you author (SKILL.md directories under `~/.claude/skills/` or a repo's `.claude/skills/`) must be written in Ruby, not Python/bash/etc. — easier for me to review. Plain `bash`/CLI one-liners inline in skill steps are fine; this is about actual standalone scripts (e.g. a `scripts/*.rb` file a skill shells out to).

## Ruby / Rails
- Primary stack: Ruby on Rails
- Version manager: mise (handles Ruby, Node, and other tools)
- Testing: RSpec
- Debugging: debugger
- Linting: RuboCop - run after changes to Ruby files
- Follow existing project conventions over style guide defaults

## Credentials
- `BUNDLE_RUBYGEMS__PKG__GITHUB__COM` (GitHub Packages auth for the private `rubygems.pkg.github.com/LoanLink` gem source, needed for `bundle install` in LoanLink Ruby repos) lives in `~/.zshrc.secrets` and is already present in any shell — check with `[ -n "$BUNDLE_RUBYGEMS__PKG__GITHUB__COM" ]` before assuming it's missing, and pass it through explicitly to `docker exec` when installing inside a container. Don't go hunting other credential stores for this or similar tokens — ask if it's not found here.

## Docker
- Use Docker for development and testing when possible
- Use docker-compose for multi-container applications
- Prefer one-time run commands (docker run --rm) for ad-hoc tasks
- Keep Dockerfiles simple and efficient (multi-stage builds, minimal base images)

## Git
- Commit messages: short, imperative, lowercase (e.g., "fix login redirect")
- Follow repository format .github/PULL_REQUEST_TEMPLATE.md
- Add detailed descriptions in the body of the commit message when necessary
- Rebase workflow (pull.rebase = true, autoSquash, updateRefs)
- Push sets up remote tracking automatically (autoSetupRemote)
- Wait for confirmation before commiting and pushing to remote branches

## Environment
- macOS, zsh, Neovim, tmux, iTerm2
- Shell plugin manager: Antigen
- Dotfiles at ~/dotfiles
  - When adding a new tool, or changing config files, make sure you edit the ~/dotfiles repo and add the necessary symlinks in install.sh
