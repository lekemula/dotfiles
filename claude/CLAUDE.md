# Global Preferences

## General
- Be concise. Skip obvious explanations.
- Don't add method comments unnecessarily. Only add comments for non-obvious code.
- Don't commit or push unless I ask.

## Ruby / Rails
- Primary stack: Ruby on Rails
- Ruby version manager: RVM
- Testing: RSpec
- Debugging: debugger
- Linting: RuboCop - run after changes to Ruby files
- Follow existing project conventions over style guide defaults

## Docker
- Use Docker for development and testing when possible
- Use docker-compose for multi-container applications
- Prefer one-time run commands (docker run --rm) for ad-hoc tasks
- Keep Dockerfiles simple and efficient (multi-stage builds, minimal base images)

## Git
- Commit messages: short, imperative, lowercase (e.g., "fix login redirect")
- Add detailed descriptions in the body of the commit message when necessary
- Rebase workflow (pull.rebase = true, autoSquash, updateRefs)
- Push sets up remote tracking automatically (autoSetupRemote)

## Environment
- macOS, zsh, Neovim, tmux, iTerm2
- Shell plugin manager: Antigen
- Dotfiles at ~/dotfiles
  - When adding a new tool, or changing config files, make sure you edit the ~/dotfiles repo and add the necessary symlinks in install.sh
