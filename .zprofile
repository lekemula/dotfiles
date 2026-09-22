# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/lekemula/.docker/bin"
# End of Docker Desktop section.

# Login shells only, sourced after /etc/zprofile. Owned by dotfiles — anything an
# installer (Docker Desktop, Homebrew) appends here must be mirrored in the repo.

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Docker Desktop
export PATH="$PATH:$HOME/.docker/bin"

# macOS's /etc/zprofile runs path_helper, which hoists /usr/bin back above
# whatever .zshenv prepended, and brew shellenv above pushes homebrew in front
# too. Re-source .zshenv last so login shells — including non-interactive ones
# like `zsh -lc`, which never read .zshrc — still find mise-managed tools first.
source ~/.zshenv
