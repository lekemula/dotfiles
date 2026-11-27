# Define custom environment variables.
# This will overwrite any environment variables defined by `core/environment.zsh`.

# Detect the current OS
# 'darwin' = MacOS
# 'linus'  = linux
export ZSH_HOST_OS=$(uname | awk '{print tolower($0)}')

# Rex supports kitty graphics but its XTVERSION reply doesn't name kitty/ghostty,
# so Claude Code falls back to blocky half-block image thumbnails without this.
if [ -n "$REX_BLOCK" ]; then export CLAUDE_CODE_FORCE_TERMINAL_IMAGES=1; fi
