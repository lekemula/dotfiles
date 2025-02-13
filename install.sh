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
[ ! -d ~/.config/solargraph ] && mkdir -p ~/.config/solargraph
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.solargraph.yml ~/.config/solargraph/config.yml
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/btop.conf ~/.config/btop/btop.conf

[ ! -d ~/vim ] && mkdir ~/vim
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json ~/vim/coc-settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/my-snippets ~/vim/my-snippets
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/configs ~/vim/configs
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/setcolors.vim ~/vim/setcolors.vim

NEOVIM_CONFIG_DIR=~/.config/nvim
[ ! -d $NEOVIM_CONFIG_DIR ] && mkdir -p $NEOVIM_CONFIG_DIR
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/nvim/init.lua $NEOVIM_CONFIG_DIR/init.lua
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json ~/.config/nvim/coc-settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/lazygit.yml ~/.config/lazygit/config.yml
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/lazydocker.yml ~/.config/lazydocker/config.yml

VIMSPECTOR_GADGETS_DIR=~/vim/plugged/vimspector/gadgets/custom
[ ! -d $VIMSPECTOR_GADGETS_DIR ] && mkdir -p $VIMSPECTOR_GADGETS_DIR
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/vim/vimspector/gadgets/custom/cust_vscode-ruby.json  $VIMSPECTOR_GADGETS_DIR/cust_vscode-ruby.json

if ! command -v imgcat &> /dev/null; then
  # https://iterm2.com/documentation-images.html
  sudo curl https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
  sudo chmod +x /usr/local/bin/imgcat
fi
