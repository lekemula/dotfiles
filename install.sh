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
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.zshrc ~/.zshrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/aliases.zsh ~/.aliases.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.vimrc ~/.vimrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.p10k.zsh ~/.p10k.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.fzf.zsh ~/.fzf.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.gitignore_global ~/.gitignore_global
[ ! -d ~/.vim ] && mkdir ~/.vim
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json ~/.vim/coc-settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.vim/my-snippets ~/.vim/my-snippets

# https://iterm2.com/documentation-images.html
# FIXME
# curl https://iterm2.com/utilities/imgcat >> /opt/dev/bin/user/imgcat
# chmod +x /opt/dev/bin/user/imgcat
