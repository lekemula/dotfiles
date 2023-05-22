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
antigen apply

source $DF_HOME/custom.zsh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
