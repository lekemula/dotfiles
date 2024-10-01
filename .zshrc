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

# Load Angular CLI autocompletion.
source <(ng completion script)
export EDITOR="vim"

# Azure CLI completion
source $(brew --prefix)/etc/bash_completion.d/az

# Change config dir for lazygit
export XDG_CONFIG_HOME="$HOME/.config"

export BAT_THEME="gruvbox-dark"

if [ -f ~/.zshrc.secrets ]; then
  # This file is not checked into source control
  source ~/.zshrc.secrets 

  if [ -z $JIRA_API_TOKEN ]; then
    echo "${fg[red]}JIRA_API_TOKEN is not set. Please set it in ~/.zshrc.secrets${reset_color}"
    echo "${fg[red]}You can get the value by running 'op read \"op://vpqefcys2zayxb3ojzxxux3wpe/DevPal - Jira API Key/API Key\" --account=baufi24.1password.eu'${reset_color}"
  fi

  if [ -z $BUNDLE_RUBYGEMS__PKG__GITHUB__COM ]; then
    echo "${fg[red]}BUNDLE_RUBYGEMS__PKG__GITHUB__COM is not set. Please set it in ~/.zshrc.secrets${reset_color}"
    echo "${fg[red]}You can get the value by running 'gh auth status --show-token'${reset_color}"
  fi
else
  echo "${fg[red]}No ~/.zshrc.secrets file found. Please create one.${reset_color}"
  echo "${fg[red]}You can copy the template from ~/.zshrc.secrets.example${reset_color}"
  echo "${fg[red]}Run: cp ~/dotfiles/.zshrc.secrets.example ~/.zshrc.secrets${reset_color}"
fi
