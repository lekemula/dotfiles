# Define any custom environment scripts here.
# This file is loaded after everything else, but before Antigen is applied and ~/extra.zsh sourced.
# Put anything here that you want to exist on all your environment, and to have the highest priority
# over any other customization.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Shopify dev tool
[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

# Shopify spin completion
if [[ $(which spin) != *'not found' ]]; then
  autoload -Uz compinit && compinit
  source <(spin completion --shell=zsh)
fi

source ~/.aliases.zsh
