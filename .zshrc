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

# zsh-autocomplete must be sourced before zsh-vi-mode (antigen), otherwise
# zsh-vi-mode resets all widgets and Tab breaks.
zstyle ':autocomplete:*' async yes
zstyle ':completion:*' use-cache yes
zstyle ':autocomplete:*' fzf-completion no
zstyle ':autocomplete:*' recent-dirs no
zstyle ':autocomplete:*' widget-style menu-select
zstyle ':autocomplete:*' delay 0.2
source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

export ZVM_VI_ESCAPE_BINDKEY=jj # zsh-vi-mode
# Load zsh plugins via Antigen
source ~/antigen/antigen.zsh
# Use antigen init for better performance
antigen init ~/.antigenrc

# Plugins conflicting with zsh-vi-mode
function zvm_after_init() {
  # Fix fzf tab completion with zsh-vi-mode
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  # https://github.com/junegunn/fzf-git.sh/issues/23#issuecomment-2130793362
  bindkey -r '^G'
  # Fuzzy git object searching
  source $DF_HOME/fzf-git.sh

  # Restore keybindings that zsh-vi-mode resets
  bindkey '^I' autosuggest-accept     # Tab → zsh-autosuggestions
  bindkey '^N' menu-select            # Ctrl+N → open/navigate autocomplete menu
  bindkey '^P' reverse-menu-complete  # Ctrl+P → reverse navigate
  bindkey -M menuselect '^N' menu-complete
  bindkey -M menuselect '^P' reverse-menu-complete

  # Use Ctrl-F for fzf file completion instead of **<tab>
  bindkey '^F' fzf-file-widget
  bindkey '^T' fzf-file-widget
  bindkey '^R' fzf-history-widget
}

source $DF_HOME/custom.zsh

fpath=(~/.zsh/Completion $fpath)
fpath=($(brew --prefix)/share/zsh/site-functions ${fpath})

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"
export NODE_PATH=`npm root -g`

# Load Angular CLI autocompletion.
source <(ng completion script)
export EDITOR="nvim"

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

eval "$(zoxide init zsh)"


# AsyncAPI CLI Autocomplete

ASYNCAPI_AC_ZSH_SETUP_PATH=/Users/lekemula/Library/Caches/@asyncapi/cli/autocomplete/zsh_setup && test -f $ASYNCAPI_AC_ZSH_SETUP_PATH && source $ASYNCAPI_AC_ZSH_SETUP_PATH; # asyncapi autocomplete setup

source $DF_HOME/tmux-nvim-click.zsh

export PATH="/Users/lekemula/Projects/finlink/dev-pal/exe:$PATH"

# Primarily for Claude Github Plugin
export GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)

# https://github.com/anomalyco/opencode/issues/7405#issuecomment-4018473781
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
