# Custom configs for MacOS environments.
# This file will only be executed if the current environment is MacOS.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -z $(which brew) ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -z $(which vim) ]]; then
  brew install vim
fi

if [[ -z $(which node) ]]; then
  brew install node 
fi

if [[ -z $(which the_silver_searcher) ]]; then
  brew install the_silver_searcher
fi

