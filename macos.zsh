# Custom configs for MacOS environments.
# This file will only be executed if the current environment is MacOS.

if [[ $(uname -m) == "arm64" ]]; then
  is_apple_silicon_chip="true"
else
  is_apple_silicon_chip="false"
fi

# Antigen's oh-my-zsh bundle expects this completions cache dir to exist before
# plugins like mise, helm, and docker source their completion files. Create it
# unconditionally — $ZSH_CACHE_DIR isn't set until oh-my-zsh loads later, so we
# hardcode the antigen bundle path here.
ANTIGEN_OMZ_CACHE="$HOME/.antigen/bundles/robbyrussell/oh-my-zsh/cache/completions"
[[ ! -d "$ANTIGEN_OMZ_CACHE" ]] && mkdir -p "$ANTIGEN_OMZ_CACHE"

# Install homebrew if not installed
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install a Homebrew cask, self-healing if brew's metadata is stale (i.e. the app
# bundle was deleted/moved but the cask is still tracked). Plain `brew install`
# refuses to re-place a missing app in that case, so fall back to `reinstall`.
# Returns 0 only when it performed an (re)install, so callers can gate post-steps.
install_cask() {
  local app_path="$1" cask="$2"
  [[ -e "$app_path" ]] && return 1
  if brew list --cask "$cask" &> /dev/null; then
    brew reinstall --cask "$cask"
  else
    brew install --cask "$cask"
  fi
}

# macOS system vim ships with +conceal but -python3, which Vimspector requires.
# Check for +python3 so Homebrew's vim (has both) gets installed and takes PATH priority.
# https://github.com/ryanoasis/vim-devicons/issues/215#issuecomment-346231411
if [[ -z $(which vim) ]] || [[ -z $(vim --version | grep "\+python3") ]]; then
  brew install python3
  brew install vim
fi

if ! command -v nvim &> /dev/null; then
  brew install neovim
fi

# pynvim must be installed for the same python3 nvim uses, otherwise
# has('python3') is 0 and plugins like UltiSnips fail to load. Guard
# independently from nvim so it self-heals if pynvim is missing for any
# reason (fresh Python, reinstalled brew formulae, etc.).
if ! python3 -c "import pynvim" &> /dev/null; then
  pip3 install --user pynvim --break-system-packages
fi

# check if exuberant-ctags is installed and install it if not
if [[ -z $(which ctags) ]]; then
  brew install universal-ctags
fi

if ! command -v mise &> /dev/null; then
  brew install mise
fi

# Install Node.js via mise (includes npm)
if command -v mise &> /dev/null && ! mise list node 2>/dev/null | grep -q node; then
  mise install node@lts
  mise use --global node@lts
fi

# The mise antigen plugin loads after macos.zsh, so npm/node shims aren't on PATH
# yet during a fresh install. Activate shims here so the rest of this script can
# run `npm install --global ...` without "npm: command not found".
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh --shims)"
fi

if command -v npm &> /dev/null && ! command -v yarn &> /dev/null; then
  npm install --global yarn
fi

if ! command -v ng &> /dev/null; then
  npm install --global @angular/cli
fi

if ! command -v typescript-language-server &> /dev/null; then
  npm install --global typescript-language-server
  npm install --global angular/language-service
  npm install --global vscode-langservers-extracted
fi

if ! command -v yaml-language-server &> /dev/null; then
  npm install --global yaml-language-server
fi

# https://github.com/ggreer/the_silver_searcher
if ! command -v ag &> /dev/null; then
  brew install the_silver_searcher
fi

# https://github.com/junegunn/fzf
# Guard on the binary, not ~/.fzf.zsh — install.sh symlinks ~/.fzf.zsh before this
# script runs, so a path check would always be true and skip the brew install.
if ! command -v fzf &> /dev/null; then
  brew install fzf

  # To install useful key bindings and fuzzy completion:
  $(brew --prefix)/opt/fzf/install
fi

if install_cask "/Applications/iTerm.app" iterm2; then
  defaults write com.googlecode.iterm2 ApplePressAndHoldEnabled -bool false
fi

# Faster key repeat for navigation/editing. Skip the write if already set so this
# doesn't run on every shell startup. Requires logout/restart to take effect.
if [[ $(defaults read NSGlobalDomain KeyRepeat 2>/dev/null) != "2" ]]; then
  defaults write NSGlobalDomain KeyRepeat -int 2          # repeat rate (min 1)
  defaults write NSGlobalDomain InitialKeyRepeat -int 15  # delay before repeat (min 15)
  echo "Set faster key repeat — log out and back in for it to take effect."
fi

# https://www.geekbits.io/how-to-install-nerd-fonts-on-mac/
if [[ -z $(brew list font-meslo-lg-nerd-font) ]]; then
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font # my current favorite
  # Other's to consider
  brew install --cask font-roboto-mono-nerd-font # google's
  brew install --cask font-hack-nerd-font
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-fira-mono-nerd-font
  brew install --cask font-monaspace-nerd-font # github's
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask font-caskaydia-mono-nerd-font # microsoft
  echo "Don't forget to set your font settings in Iterm2 to 'MesloLGS NF': https://webinstall.dev/nerdfont/"
  echo "Press Enter to continue..."
  read
fi

# Install google chrome if not installed
install_cask "/Applications/Google Chrome.app" google-chrome

install_cask "/Applications/1Password.app" 1password

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

if ! command -v clangd &> /dev/null; then
  brew install llvm
fi

if ! command -v watchman &> /dev/null; then
  brew install watchman # Required by solargraph and coc-tsserver
fi

install_cask "/Applications/Docker.app" docker

if ! command -v tmux &> /dev/null; then
  brew install tmux
fi

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # Install tmux plugins non-interactively: tpm's install_plugins script needs a
  # running tmux server with the config sourced so it can read the @plugin list.
  if [[ -f ~/.tmux.conf ]]; then
    tmux start-server \; new-session -d \; source-file ~/.tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
    tmux kill-server
  else
    echo "~/.tmux.conf not found yet — run install.sh first, then re-run this script to install tmux plugins."
  fi
fi

if ! command -v go &> /dev/null; then
  brew install go
fi

install_cask "/Applications/logioptionsplus.app" logi-options-plus

# https://www.caffeine-app.net/ — keeps the Mac awake
install_cask "/Applications/Caffeine.app" caffeine

# https://rectangleapp.com/
if install_cask "/Applications/Rectangle.app" rectangle; then
  echo "Import Rectangle settings from RectangleConfig.json"
  echo "Press Enter to continue..."
  read
fi

# https://www.raycast.com/
if install_cask "/Applications/Raycast.app" raycast; then
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

# Structural, syntax-aware diffs, used on demand via the git ddiff/dshow/dlog
# aliases in .gitconfig. https://github.com/Wilfred/difftastic
if ! command -v difft &> /dev/null; then
  brew install difftastic
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

if ! command -v vscode-json-language-server &> /dev/null; then
  npm install --global vscode-langservers-extracted
fi

if ! command -v lazydocker &> /dev/null; then
  brew install lazydocker
fi

if ! command -v lazygit &> /dev/null; then
  brew install lazygit
fi

install_cask "/Applications/Loom.app" loom

install_cask "/Applications/Spotify.app" spotify

# Monosnap — not on Homebrew (removed due to download issues).
# Install manually from https://monosnap.com/ or the Mac App Store.
if [[ ! -e "/Applications/Monosnap.app" ]]; then
  echo "Install Monosnap manually from https://monosnap.com/ or the Mac App Store."
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

# https://formulae.brew.sh/cask/claude-code@latest — Claude Code CLI, tracks the latest release
install_cask "/opt/homebrew/bin/claude" claude-code@latest

# https://claude.ai/download — Claude desktop app
install_cask "/Applications/Claude.app" claude

# Review-first terminal diff viewer — https://github.com/modem-dev/hunk
if ! command -v hunk &> /dev/null; then
  brew install hunk
  ln -vsfn "$(brew --prefix hunk)/libexec/skills/hunk-review" ~/.claude/skills/hunk-review
fi

if ! command -v tree &> /dev/null; then
  brew install tree
fi

if ! command -v dive &> /dev/null; then
  brew install dive
fi

# agrind: slice/aggregate logs with a SQL-ish DSL. https://github.com/rcoh/angle-grinder
if ! command -v agrind &> /dev/null; then
  brew install angle-grinder
fi

# zsh-autocomplete via brew
if [[ ! -d "$HOMEBREW_PREFIX/opt/zsh-autocomplete" ]]; then
  brew install zsh-autocomplete
fi

if ! command -v stimulus-language-server &> /dev/null; then
  npm install --global stimulus-language-server
fi

if ! command -v herb-language-server &> /dev/null; then
  npm install --global @herb-tools/language-server
fi

# Install mcp-hub for Neovim plugin
if ! command -v mcp-hub &> /dev/null; then
  npm install --global mcp-hub@latest
fi

# Install OpenCode for macOS
if ! command -v opencode &> /dev/null; then
  brew install opencode
fi

# https://www.postman.com/ — API client
install_cask "/Applications/Postman.app" postman
