# Custom configs for Spin environments
# This file will only be executed on Spin environments.
if [[ $SPIN ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh

  
  # Spin dotenv debugging
  # View Logs
  alias spindl='journalctl --unit dotfiles.service'
  # Refresh configs
  alias spindr='systemctl restart dotfiles.service'
fi
