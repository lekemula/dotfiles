# Custom configs for MacOS environments.
# This file will only be executed if the current environment is MacOS.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Install homebrew if not installed
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# https://github.com/ryanoasis/vim-devicons/issues/215#issuecomment-346231411
if [[ -z $(which vim) ]] || [[ -z $(vim --version | grep "\+conceal") ]]; then
  brew install vim
fi

if ! command -v nvim &> /dev/null; then
  brew install neovim
fi

# check if exuberant-ctags is installed and install it if not
if [[ -z $(which ctags) ]]; then
  brew install ctags
fi

if [[ ! -d $HOME/.nvm ]] then
  brew install nvm
  mkdir $HOME/.nvm

  export NVM_DIR="$HOME/.nvm"
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"  ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
  nvm install node
fi

# https://github.com/ggreer/the_silver_searcher
if [[ -z $(which ag) ]]; then
  brew install the_silver_searcher
fi

# https://github.com/junegunn/fzf
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

# Install google chrome if not installed
if [[ ! -e "/Applications/Google Chrome.app" ]]; then
  brew install --cask google-chrome
fi

if [[ ! -e "/Applications/1Password.app" ]]; then
  brew install --cask 1password
fi

if [[ ! -e "/usr/local/share/zsh/site-functions/_compdef" ]]; then
  brew install compdef
  autoload -Uz compinit && compinit -i
fi

# 1Passord CLI
if ! command -v op &> /dev/null; then
  brew install --cask 1password/tap/1password-cli
  echo "Follow instructions here for sign in: https://developer.1password.com/docs/cli/get-started"
  eval "$(op completion zsh)"; compdef _op op
fi

# Github CLI
if ! command -v gh &> /dev/null; then
  brew install gh
  gh auth login
  gh auth setup-git
  eval "$(gh completion -s zsh)"
  compdef _gh gh
fi

if ! command -v bat &> /dev/null; then
  brew install bat
fi

if ! command -v scala &> /dev/null; then
  brew install coursier/formulas/coursier && cs setup
fi

if ! command -v cmake &> /dev/null; then
  brew install cmake
fi

if ! command -v ccls &> /dev/null; then
  brew install ccls
fi

if [[ ! -d ~/.rvm/ ]] then
  curl -sSL https://get.rvm.io | bash
  # https://rvm.io/workflow/completion
  source ~/.rvm/scripts/rvm
  mkdir -p $HOME/.zsh/Completion
  cp $rvm_path/scripts/zsh/Completion/_rvm $HOME/.zsh/Completion
  chmod +x $rvm_path/scripts/zsh/Completion/_rvm

  rvm install ruby --latest
  gem install solargraph ruby-debug-ide

  brew install watchman # Required for solargraph
  # Required for pg gem
  brew install libpq
  brew install postgresql
fi

if [[ ! -d /Applications/Docker.app ]]; then
  brew install --cask docker
fi

if ! command -v tmux &> /dev/null; then
  brew install tmux

  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if ! command -v go &> /dev/null; then
  brew install go
fi

