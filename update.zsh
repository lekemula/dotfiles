brew upgrade
vim +PlugUpgrade +PlugUpdate +CocUpdate +qall
gh extension upgrade --all
~/.tmux/plugins/tpm/bin/update_plugins all
# antigen update - FIXME: this command is not found when running this script
gem update --system
gem update solargraph solargraph-rspec ruby-debug-ide ripper-tags gem-ripper-tags vernier profile-viewer 
npm update -g
curl https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh > fzf-git.sh
