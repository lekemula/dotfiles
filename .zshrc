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

# workmux completions — completes commands and existing worktree/branch names.
# Must stay between zsh-autocomplete and antigen: antigen's cached init replaces
# compdef with a permanent no-op (antigen.zsh:1843) until it runs compinit from a
# precmd hook, so registering after it is silently dropped. Here, the compdef is
# picked up by zsh-autocomplete's queue and replayed once compinit has run.
command -v workmux &> /dev/null && eval "$(workmux completions zsh)"

# gcloud completions — same placement constraint as workmux above. mise keeps
# the `latest` symlink current on upgrade. The az completion sourced below
# redefines `_python_argcomplete` as a zsh-native function, so gcloud gets its
# own copy under another name.
GCLOUD_COMPLETION=~/.local/share/mise/installs/gcloud/latest/completion.zsh.inc
if [ -f $GCLOUD_COMPLETION ]; then
  source $GCLOUD_COMPLETION
  functions[_gcloud_argcomplete]=$functions[_python_argcomplete]
  complete -o nospace -o default -F _gcloud_argcomplete gcloud
  complete -o nospace -F _gcloud_argcomplete gsutil
fi

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
  # Tab: accept zsh-autosuggestion if one is showing, else fall through to
  # fzf-completion so the `**<Tab>` trigger (e.g. `cd ~/Projects/**<Tab>`) and
  # normal completion still work.
  _lm_tab_hybrid() {
    if [[ -n "$POSTDISPLAY" ]]; then
      zle autosuggest-accept
    else
      zle fzf-completion
    fi
  }
  zle -N _lm_tab_hybrid
  bindkey '^I' _lm_tab_hybrid

  bindkey '^N' menu-select            # Ctrl+N → open/navigate autocomplete menu
  bindkey '^P' reverse-menu-complete  # Ctrl+P → reverse navigate
  bindkey -M menuselect '^N' menu-complete
  bindkey -M menuselect '^P' reverse-menu-complete

  # Use Ctrl-F for fzf file completion instead of **<tab>
  bindkey '^F' fzf-file-widget
  bindkey '^T' fzf-file-widget
  bindkey '^R' fzf-history-widget

  # zsh-autocomplete remaps Up/Down to a prefix-search widget; restore the
  # familiar "walk through history" behavior. Bind both the CSI and SS3
  # escape sequences so it works regardless of terminal application mode.
  bindkey '^[[A' up-line-or-history    # Up
  bindkey '^[[B' down-line-or-history  # Down
  bindkey '^[OA' up-line-or-history    # Up (application keypad mode)
  bindkey '^[OB' down-line-or-history  # Down (application keypad mode)
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

# Inside Rex, follow its terminal palette (GitHub Dark) instead of gruvbox; this
# also colours bat-based previews such as fzf.vim's.
if [[ $TERM_PROGRAM == rex ]]; then
  export BAT_THEME="ansi"
  # fzf in GitHub Dark colours, on the terminal's own background.
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=fg:#e6edf3,bg:-1,hl:#58a6ff,fg+:#ffffff,bg+:#161b22,hl+:#79c0ff,gutter:-1,query:#e6edf3,info:#8b949e,prompt:#58a6ff,pointer:#58a6ff,marker:#3fb950,spinner:#d29922,header:#8b949e,border:#30363d,separator:#30363d,scrollbar:#30363d"
else
  export BAT_THEME="gruvbox-dark"
fi

if [ -f ~/.zshrc.secrets ]; then
  # This file is not checked into source control
  source ~/.zshrc.secrets 

  # Never name this JIRA_API_TOKEN: it belongs to the it@finlink.de technical
  # user, and that generic name shadows ATLASSIAN_API_TOKEN in any tool that
  # prefers a per-product token. aliases.zsh injects it for dev-pal only.
  if [ -z $DEVPAL_JIRA_API_TOKEN ]; then
    echo "${fg[red]}DEVPAL_JIRA_API_TOKEN is not set. Please set it in ~/.zshrc.secrets${reset_color}"
    echo "${fg[red]}You can get the value by running 'op read \"op://vpqefcys2zayxb3ojzxxux3wpe/DevPal - Jira API Key/API Key\" --account=baufi24.1password.eu'${reset_color}"
  fi

  if [ -z $ATLASSIAN_API_TOKEN ]; then
    echo "${fg[red]}ATLASSIAN_API_TOKEN is not set. Please set it in ~/.zshrc.secrets${reset_color}"
    echo "${fg[red]}Create an unscoped token at https://id.atlassian.com/manage-profile/security/api-tokens (it pairs with your own email)${reset_color}"
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



# AsyncAPI CLI Autocomplete

ASYNCAPI_AC_ZSH_SETUP_PATH=/Users/lekemula/Library/Caches/@asyncapi/cli/autocomplete/zsh_setup && test -f $ASYNCAPI_AC_ZSH_SETUP_PATH && source $ASYNCAPI_AC_ZSH_SETUP_PATH; # asyncapi autocomplete setup

source $DF_HOME/tmux-nvim-click.zsh


# Primarily for Claude Github Plugin
export GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)

# https://github.com/anomalyco/opencode/issues/7405#issuecomment-4018473781
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true

# zoxide must init last, else its doctor warns that `cd` is overridden after it.
# Non-interactive shells (agents, scripts) still trip the doctor through the `cd` alias, so silence it.
export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"
