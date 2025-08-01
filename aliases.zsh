alias cd='z' # zoxide
alias ls='eza --all --grid --icons=always --group-directories-first'
alias lso='eza -1 --all --grid --icons=always --group-directories-first' # oneline
alias lst='eza --all --tree --level=1 --icons=always --group-directories-first --long --no-permissions --no-user --no-time'
alias gcofzf='git checkout $(git branch --all | fzf)'
alias gcobfzf='git checkout -b $(git branch --all | fzf)'
alias gcob='git checkout -b'
alias glot='glo --tags --no-walk --tags --no-walk'
alias mkdir='mkdir -p' # create dir recursively
alias gdb='git diff origin/main..HEAD'
alias res='omz reload' # reload zsh
alias upd='~/dotfiles/update.zsh'
alias lsport='lsof -i -P -n' # list ports
alias '??=gh copilot explain'
alias '???=gh copilot suggest'
alias ghd='gh dash'
alias gbl='git blame -w -b -C -C'
alias gbL='git blame -w -b -C -C -C'

alias lm_rspec_changed='bundle exec rspec $(git status -s | awk '\''{ print $2  }'\'' | grep spec | xargs echo)'
alias lm_rubocop_changed='bundle exec rubocop -A $(git status -s | awk '\''{ print $2  }'\'' | grep spec | xargs echo)'
alias weather='curl wttr.in'
alias kc='kubectx'
alias kns='kubens'
alias ks='kubectx && kubens'
alias ke='keti'
alias dcr='docker-compose run --rm'
alias gstap='git stash push --patch -m'

alias lzd='lazydocker'
alias lzg='lazygit'
alias tf='thefuck'
alias diff='diff -c'

# Finlink
alias flb='dcb loanlink-api-finlink'
alias fla='dcupd loanlink-api-finlink'
alias flrspec='dcr rails-test rspec'
alias flrspecd='dcupd rails-test'
alias fltest='flrspec'
alias fltestd='flrspecd'
alias flp="yq '.services[].profiles' docker-compose.yml | sort | uniq"

function lm_logseq_sync_dropbox () {
  icloud=$(eval "echo ~/Library/Mobile\ Documents/iCloud\~com\~logseq\~logseq/Documents")
  dropbox=$(eval "echo ~/Dropbox/Documents/Logseq/Personal\ \(read\ only\)")
  rsync -av "${icloud}/Personal/" $dropbox # trailing slash means copy contents of dir
}

function lm_ruby_hash_to_json () {
  ruby -r 'active_support/all' -ne 'puts binding.eval($_).to_json'
}

# Set docker compoes profile
function dcp(){
  if [ -z "$1" ]; then
    echo "Usage: dcp <profile>"
    echo "Current profiles: $COMPOSE_PROFILES"
    return 1
  fi
  export COMPOSE_PROFILES=$1
}
