# Custom configs for MacOS environments.
# This file will only be executed if the current environment is MacOS.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -z $(which brew) ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# https://github.com/ryanoasis/vim-devicons/issues/215#issuecomment-346231411
if [[ -z $(which vim) ]] || [[ -z $(vim --version | grep "\+conceal") ]]; then
  brew install vim
fi

if [[ -z $(which node) ]]; then
  brew install node 
fi

if [[ -z $(which ag) ]]; then
  brew install the_silver_searcher
fi

if [[ -z $(which fzf) ]]; then
  brew install fzf
fi

if [[ ! -e "/Applications/iTerm.app" ]]; then
  brew install --cask iterm2
  defaults write com.googlecode.iterm2 ApplePressAndHoldEnabled -bool false
fi

# https://www.geekbits.io/how-to-install-nerd-fonts-on-mac/
if [[ -z $(brew list font-meslo-lg-nerd-font) ]]; then
  brew tap homebrew/cask-fonts
  brew install font-meslo-lg-nerd-font
  echo "Don't forget to set your font settings in Iterm2 to 'MesloLGS NF': https://webinstall.dev/nerdfont/"
fi

