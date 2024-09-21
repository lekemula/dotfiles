# This script is run every time you log in. It's the entrypoint for all shell environment config.
export DOTFILES_DIRECTORY_NAME="${DOTFILES_DIRECTORY_NAME:-$([ $SPIN ] && echo "shopify-dotfiles" || echo "dotfiles")}"
export DF_HOME=~/$DOTFILES_DIRECTORY_NAME

# Create common color functions.
autoload -U colors
colors

# Set up custom environment variables
source $DF_HOME/environment.zsh

# Load configs for MacOS. Does nothing if not on MacOS
if [ "$ZSH_HOST_OS" = "darwin" ]; then
  if [ -e $DF_HOME/macos.zsh ]; then
    source $DF_HOME/macos.zsh
  fi
fi

# Load zsh plugins via Antigen
source ~/antigen/antigen.zsh
source $DF_HOME/antigen_bundles.zsh
# remove comment for line below to update antigen bundles
# bat $DF_HOME/antigen_bundles.zsh
antigen apply

source $DF_HOME/custom.zsh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
fpath=(~/.zsh/Completion $fpath)
fpath=($(brew --prefix)/share/zsh/site-functions ${fpath})

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"  ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"
export GITHUB_TOKEN=$(gh auth token)

# Load Angular CLI autocompletion.
source <(ng completion script)
export EDITOR="vim"

# Azure CLI completion
source $(brew --prefix)/etc/bash_completion.d/az

# Change config dir for lazygit
export XDG_CONFIG_HOME="$HOME/.config"

export BAT_THEME="gruvbox-dark"
