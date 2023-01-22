# Custom actions to take on initial install of dotfiles.

if [ $SHOPIFY ]; then
  source ~/$DOTFILES_DIRECTORY_NAME/personal/environment.zsh
else
  source $PWD/environment.zsh
  # Load configs for MacOS. Does nothing if not on MacOS
  if [ "$ZSH_HOST_OS" = "darwin" ]; then
    source ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/macos.zsh
  fi
fi


# This runs after default install actions, so you can overwrite changes it makes if you want.
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.vimrc ~/.vimrc
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.p10k.zsh ~/.p10k.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.fzf.zsh ~/.fzf.zsh
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.gitignore_global ~/.gitignore_global
[ ! -d ~/.vim ] && mkdir ~/.vim
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/coc-settings.json ~/.vim/coc-settings.json
ln -vsfn ~/$PERSONAL_DOTFILES_DIRECTORY_NAME/.vim/my-snippets ~/.vim/my-snippets

# https://iterm2.com/documentation-images.html
curl https://iterm2.com/utilities/imgcat >> /opt/dev/bin/user/imgcat
chmod +x /opt/dev/bin/user/imgcat
