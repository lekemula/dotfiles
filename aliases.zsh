alias gcofzf='git checkout $(git branch --all | fzf)'
alias gcobfzf='git checkout -b $(git branch --all | fzf)'
alias gcob='git checkout -b'
alias mkdir='mkdir -p' # create dir recursively
alias gdb='git diff origin/main..HEAD'
alias res='omz reload' # reload zsh
alias lsport='lsof -i -P -n' # list ports
alias '??=gh copilot explain'
alias '???=gh copilot suggest'

alias lm_rspec_changed='bundle exec rspec $(git status -s | awk '\''{ print $2  }'\'' | grep spec | xargs echo)'

