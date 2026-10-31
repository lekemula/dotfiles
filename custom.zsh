# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ $TERM_PROGRAM == rex && -f ${DF_HOME:-$HOME/dotfiles}/.p10k.rex.zsh ]] && source ${DF_HOME:-$HOME/dotfiles}/.p10k.rex.zsh

# Rex tab history for ctrl+b ctrl+l (rex/tab-history.lua): one watcher, started by
# whichever Rex shell opens first, since Rex config can't keep a process running.
if [[ $TERM_PROGRAM == rex ]] && ! pgrep -qf 'rex do --all .*tab-history.lua'; then
  (rex do --all ~/.config/rex/tab-history.lua dir=$HOME/.config/rex >/dev/null 2>&1 &!)
fi

# Shopify dev tool
[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

# Shopify spin completion
if [[ $(which spin) != *'not found' ]]; then
  source <(spin completion --shell=zsh)
fi

source ~/.aliases.zsh

eval $(thefuck --alias)

# source $HOME/.config/op/plugins.sh
