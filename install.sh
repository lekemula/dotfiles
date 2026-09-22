# Custom actions to take on initial install of dotfiles.

# Install the antigen plugin/theme manager if it's not already installed.
if [[ ! -d $HOME/antigen ]]; then
	echo -e "Antigen not found, installing..."
	cd $HOME
	git clone https://github.com/zsh-users/antigen.git
	cd -
fi

if [[ -z $(gem list solargraph | grep solargraph) ]]; then
  gem install solargraph
fi

# This runs after default install actions, so you can overwrite changes it makes if you want.
if [[ -z "$WITHOUT_ZSHRC_SYMLINK" ]]; then
  # Create a symlink to the zshrc file in the dotfiles directory.
  ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.zshrc ~/.zshrc
fi

# .zshenv is read by non-interactive shells too, unlike .zshrc — that's where the
# mise shims PATH prepend lives, so agent tooling and scripts get the right Ruby.
# .zprofile re-sources it, because /etc/zprofile's path_helper undoes the prepend
# for login shells.
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.zshenv ~/.zshenv
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.zprofile ~/.zprofile

CONFIG_DIR=~/.config
[ ! -d $CONFIG_DIR ] && mkdir -p $CONFIG_DIR

ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/aliases.zsh ~/.aliases.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.vimrc ~/.vimrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.p10k.zsh ~/.p10k.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.fzf.zsh ~/.fzf.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.tmux.conf ~/.tmux.conf
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.gitconfig ~/.gitconfig
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.gitignore_global ~/.gitignore_global
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.gitattributes ~/.gitattributes
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.pryrc ~/.pryrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.rdbgrc ~/.rdbgrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.antigenrc ~/.antigenrc
[ ! -d ~/.claude ] && mkdir -p ~/.claude
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude.json ~/.claude/settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/skills ~/.claude/skills
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/agents ~/.claude/agents
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/keybindings.json ~/.claude/keybindings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/statusline.sh ~/.claude/statusline.sh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/subagent-statusline.sh ~/.claude/subagent-statusline.sh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/MEMORY.md ~/.claude/MEMORY.md
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/plugins ~/.claude/local-plugins

# hunk bundles its review skill inside its install prefix; link it in so Claude Code discovers it
if command -v hunk >/dev/null 2>&1; then
  # `hunk skill path` points into the versioned Cellar, which breaks on upgrade; prefer brew's stable opt prefix
  hunk_skill_dir="$(dirname "$(hunk skill path)")"
  if command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix hunk 2>/dev/null)/libexec/skills/hunk-review" ]; then
    hunk_skill_dir="$(brew --prefix hunk)/libexec/skills/hunk-review"
  fi
  ln -vsfn "$hunk_skill_dir" ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/claude/skills/hunk-review
fi
[ ! -d $CONFIG_DIR/solargraph ] && mkdir -p $CONFIG_DIR/solargraph
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.solargraph.yml $CONFIG_DIR/solargraph/config.yml
[ ! -d $CONFIG_DIR/btop ] && mkdir -p $CONFIG_DIR/btop
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/btop.conf $CONFIG_DIR/btop/btop.conf
[ ! -d $CONFIG_DIR/mise ] && mkdir -p $CONFIG_DIR/mise
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/mise.config.toml $CONFIG_DIR/mise/config.toml
[ ! -d $CONFIG_DIR/hunk ] && mkdir -p $CONFIG_DIR/hunk
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/hunk.config.toml $CONFIG_DIR/hunk/config.toml
[ ! -d $CONFIG_DIR/herdr ] && mkdir -p $CONFIG_DIR/herdr
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/herdr.config.toml $CONFIG_DIR/herdr/config.toml
[ ! -d $CONFIG_DIR/workmux ] && mkdir -p $CONFIG_DIR/workmux
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/workmux.config.yaml $CONFIG_DIR/workmux/config.yaml

[ ! -d ~/.logseq/config ] && mkdir -p ~/.logseq/config
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/logseq.edn ~/.logseq/config/config.edn

[ ! -d ~/vim ] && mkdir ~/vim
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json ~/vim/coc-settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/my-snippets ~/vim/my-snippets
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/configs ~/vim/configs
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/setcolors.vim ~/vim/setcolors.vim

NEOVIM_CONFIG_DIR=$CONFIG_DIR/nvim
[ ! -d $NEOVIM_CONFIG_DIR ] && mkdir -p $NEOVIM_CONFIG_DIR
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/nvim/* $NEOVIM_CONFIG_DIR
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json $NEOVIM_CONFIG_DIR/coc-settings.json
[ ! -d $CONFIG_DIR/lazygit ] && mkdir -p $CONFIG_DIR/lazygit
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/lazygit.yml $CONFIG_DIR/lazygit/config.yml
[ ! -d $CONFIG_DIR/lazydocker ] && mkdir -p $CONFIG_DIR/lazydocker
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/lazydocker.yml $CONFIG_DIR/lazydocker/config.yml

VIMSPECTOR_GADGETS_DIR=~/vim/plugged/vimspector/gadgets/custom
[ ! -d $VIMSPECTOR_GADGETS_DIR ] && mkdir -p $VIMSPECTOR_GADGETS_DIR
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/vimspector/gadgets/custom/cust_vscode-ruby.json  $VIMSPECTOR_GADGETS_DIR/cust_vscode-ruby.json

ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/bin/tmux-nvim-click.sh /usr/local/bin/tmux-nvim-click.sh
[ ! -d $CONFIG_DIR/mcphub ] && mkdir -p $CONFIG_DIR/mcphub
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/nvim/mcphub/servers.json $CONFIG_DIR/mcphub/servers.json
[ ! -d $CONFIG_DIR/opencode ] && mkdir -p $CONFIG_DIR/opencode
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/opencode.json $CONFIG_DIR/opencode/opencode.json

if ! command -v imgcat &> /dev/null; then
  # https://iterm2.com/documentation-images.html
  sudo curl https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
  sudo chmod +x /usr/local/bin/imgcat
fi

# Create symlinks for custom scripts in bin directory
BIN_DIR=~/$PERSONAL_DOTFILES_DIRECTORY_NAME/bin
if [ -d $BIN_DIR ]; then
  for script in $BIN_DIR/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
      script_name=$(basename "$script")
      sudo ln -vsfn "$script" "/usr/local/bin/$script_name"
    fi
  done
fi
