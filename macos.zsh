# Custom configs for MacOS environments.
# This file will only be executed if the current environment is MacOS.

if [[ $(uname -m) == "arm64" ]]; then
  is_apple_silicon_chip="true"
else
  is_apple_silicon_chip="false"
fi

# Install homebrew if not installed
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# https://github.com/ryanoasis/vim-devicons/issues/215#issuecomment-346231411
if [[ -z $(which vim) ]] || [[ -z $(vim --version | grep "\+conceal") ]]; then
  brew install python3
  brew install vim
fi

if ! command -v nvim &> /dev/null; then
  brew install neovim
  # Install pynvim for neovim python support
  pip3 install --user pynvim --break-system-packages
fi

# check if exuberant-ctags is installed and install it if not
if [[ -z $(which ctags) ]]; then
  brew install universal-ctags
fi

if [[ ! -d $HOME/.nvm ]] then
  brew install nvm
  mkdir $HOME/.nvm

  export NVM_DIR="$HOME/.nvm"
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"  ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
  nvm install node
  npm install --global yarn
fi

if ! command -v ng &> /dev/null; then
  npm install --global @angular/cli
fi

if ! command -v typescript-language-server &> /dev/null; then
  npm install --global typescript-language-server
  npm install --global angular/language-service
fi

if ! command -v yaml-language-server &> /dev/null; then
  npm install --global yaml-language-server
fi

# https://github.com/ggreer/the_silver_searcher
if ! command -v ag &> /dev/null; then
  brew install the_silver_searcher
fi

# https://github.com/junegunn/fzf
if [[ ! -e "$HOME/.fzf.zsh" ]]; then
  brew install fzf

  # To install useful key bindings and fuzzy completion:
  $(brew --prefix)/opt/fzf/install
fi

if [[ ! -e "/Applications/iTerm.app" ]]; then
  brew install --cask iterm2
  defaults write com.googlecode.iterm2 ApplePressAndHoldEnabled -bool false
fi

# https://www.geekbits.io/how-to-install-nerd-fonts-on-mac/
if [[ -z $(brew list font-meslo-lg-nerd-font) ]]; then
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font # my current favorite
  # Other's to consider
  brew install --cask font-roboto-mono-nerd-font # google's
  brew install --cask font-hack-nerd-font
  brew brew install --cask font-fira-code-nerd-font
  brew install --cask font-fira-mono-nerd-font
  brew install --cask font-monaspace-nerd-font # github's
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask font-caskaydia-mono-nerd-font # microsoft
  echo "Don't forget to set your font settings in Iterm2 to 'MesloLGS NF': https://webinstall.dev/nerdfont/"
  echo "Press Enter to continue..."
  read
fi

# Install google chrome if not installed
if [[ ! -e "/Applications/Google Chrome.app" ]]; then
  brew install --cask google-chrome
fi

if [[ ! -e "/Applications/1Password.app" ]]; then
  brew install --cask 1password
fi

# 1Passord CLI
if ! command -v op &> /dev/null; then
  brew install --cask 1password/tap/1password-cli
  eval "$(op completion zsh)"; compdef _op op
  echo "Follow instructions here for sign in: https://developer.1password.com/docs/cli/get-started"
  echo "Press Enter to continue..."
  read
fi

# Github CLI
if ! command -v gh &> /dev/null; then
  brew install gh
  brew install --cask git-credential-manager
  gh auth login
  gh auth setup-git
  eval "$(gh completion -s zsh)"
  compdef _gh gh
  gh extension install github/gh-copilot
  gh extension install dlvhdr/gh-dash
fi

if ! command -v bat &> /dev/null; then
  brew install bat
fi

if ! command -v scala &> /dev/null; then
  brew install coursier/formulas/coursier

  if [[ $is_apple_silicon_chip == "true" ]]; then
    brew install scala
  else
    cs setup
  fi
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

  if [[ $is_apple_silicon_chip == "true" ]]; then
    rvm install ruby --latest
  else
    # Make sure to install ruby before tmux due to issues with openssl@3
    # https://github.com/rvm/rvm/issues/5254#issuecomment-1635288856
    rvm install ruby --latest -C --with-openssl-dir=/opt/local/libexec/openssl11
  fi

  gem install solargraph solargraph-rspec ruby-debug-ide ripper-tags gem-ripper-tags vernier profile-viewer bundle_update_interactive
  # Required for pg gem
  brew install libpq
  brew install postgresql
fi

if ! command -v watchman &> /dev/null; then
  brew install watchman # Required by solargraph and coc-tsserver
fi

if [[ ! -d /Applications/Docker.app ]]; then
  brew install --cask docker


  # Antigen docker plugin experts this directory to be present
  if [[ ! -d "$ZSH_CACHE_DIR/completions/"  ]]; then
    mkdir -p $ZSH_CACHE_DIR/completions
  fi
fi

if ! command -v tmux &> /dev/null; then
  brew install tmux

  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "Don't forget to install tmux plugins \"<C-b> + I\" after starting a new tmux session: \"tmux start-session\""
  echo "Press Enter to continue..."
  read
fi

if ! command -v go &> /dev/null; then
  brew install go
fi

if [[ ! -e "/Applications/logioptionsplus.app" ]]; then
  brew install --cask logi-options-plus
fi

# https://rectangleapp.com/
if [[ ! -e "/Applications/Rectangle.app" ]]; then
  brew install --cask rectangle
  echo "Import Rectangle settings from RectangleConfig.json"
  echo "Press Enter to continue..."
  read
fi

# https://www.raycast.com/
if [[ ! -e "/Applications/Raycast.app" ]]; then
  brew install --cask raycast
  echo "Import Raycast settings from RaycastConfig.json"
  echo "Press Enter to continue..."
  read
fi

# https://www.pgcli.com/
if ! command -v pgcli &> /dev/null; then
  brew install pgcli
fi

# https://fx.wtf/
# CLI JSON viewer
if ! command -v fx &> /dev/null; then
  brew install fx
fi

if ! command -v terraform &> /dev/null; then
  brew tap hashicorp/tap
  brew install terraform
fi

# install prettier
if ! command -v prettier &> /dev/null; then
  npm install --global prettier
fi

# Command line correction
if ! command -v thefuck &> /dev/null; then
  brew install thefuck
fi

# Better git diff previews
if ! command -v delta &> /dev/null; then
  brew install git-delta
fi

if ! command -v terraform-ls &> /dev/null; then
  brew install hashicorp/tap/terraform-ls
fi

if ! command -v fswatch &> /dev/null; then
  brew install fswatch
fi

if ! command -v kubectl &> /dev/null; then
  brew install kubectl
fi

if ! command -v kubectx &> /dev/null; then
  brew install kubectx
fi

if ! command -v az &> /dev/null; then
  brew install azure-cli
fi

if ! command -v helm &> /dev/null; then
  brew install helm
fi

if ! command -v helm_ls &> /dev/null; then
  brew install helm-ls
fi

# Required for helm LSP to complete Kubernetes
if ! command -v yaml-language-server &> /dev/null; then
  npm install --global yaml-language-server 
fi

if ! command -v lazydocker &> /dev/null; then
  brew install lazydocker
fi

if ! command -v lazygit &> /dev/null; then
  brew install lazygit
fi

if [ ! -e '/Applications/Loom.app' ]; then
  brew install --cask loom
fi

if ! command -v btop &> /dev/null; then
  brew install btop
fi

if ! command -v tldr &> /dev/null; then
  brew install tldr
fi

if ! command -v zoxide &> /dev/null; then
  brew install zoxide
fi

if ! command -v eza &> /dev/null; then
  brew install eza
fi

if ! command -v k9s &> /dev/null; then
  brew install k9s
fi

if ! command -v git-absorb &> /dev/null; then
  brew install git-absorb
fi

if ! command -v lua-language-server &> /dev/null; then
  brew install lua-language-server
fi

if ! command -v cargo &> /dev/null; then
  brew install rust
fi

if ! command -v claude  &> /dev/null; then
  npm install -g @anthropic-ai/claude-code
fi

if ! command -v tree &> /dev/null; then
  brew install tree
fi

if ! command -v dive &> /dev/null; then
  brew install dive
fi

# zsh-autocomplete via brew
if [[ ! -d "$HOMEBREW_PREFIX/opt/zsh-autocomplete" ]]; then
  brew install zsh-autocomplete
fi
