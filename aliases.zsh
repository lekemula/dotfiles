alias gcofzf='git checkout $(git branch --all | fzf)'
alias gcobfzf='git checkout -b $(git branch --all | fzf)'
alias gcob='git checkout -b'
alias mkdir='mkdir -p' # create dir recursively
alias gdb='git diff origin/main..HEAD'
alias res='omz reload' # reload zsh
alias lsport='lsof -i -P -n' # list ports
alias '??=gh copilot explain'
alias '???=gh copilot suggest'
alias gbl='git blame -w -b -C -C -C'

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

function lm_logseq_sync_dropbox () {
  icloud=$(eval "echo ~/Library/Mobile\ Documents/iCloud\~com\~logseq\~logseq/Documents")
  dropbox=$(eval "echo ~/Dropbox/Documents/Logseq/Personal\ \(read\ only\)")
  rsync -av "${icloud}/Personal/" $dropbox # trailing slash means copy contents of dir
}

# Set docker compoes profile
function dcp(){
  export COMPOSE_PROFILES=$1
}
