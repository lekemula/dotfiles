# Custom configs for Spin environments
# This file will only be executed on Spin environments.
if [[ $SPIN ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh

  
  # Spin dotenv debugging
  # View Logs
  alias spin_logs='journalctl --unit dotfiles.service'
  # Refresh configs
  alias restart_all='systemctl restart dotfiles.service'
  alias spindr='systemctl restart dotfiles.service'

  # Run style on changed filed
  alias ds='dev style $(git diff --name-only)'
  alias dss='dev style $(git diff --staged --name-only)'
  alias dsb='dev style --include-branch-commits'

  read -r -d '' sql_cheatsheet <<'SQL'
MySQL CLI cheatsheet:
  * show databases;
  * use shopify_dev_shard_0;
  * show tables;
  * show columns from checkouts;
SQL

  alias sql='echo $sql_cheatsheet && mysql -u root -P $MYSQL_PORT'

  # if vim version is not 9
  if [[ $(vim --version | head -n 1 | cut -d ' ' -f 5 | cut -d '.' -f 1) -ne 9 ]]; then
    # Install the latest version of vim for Github Copilot
    sudo add-apt-repository ppa:jonathonf/vim
    sudo apt update
    sudo apt-get install -y vim
  fi
fi
