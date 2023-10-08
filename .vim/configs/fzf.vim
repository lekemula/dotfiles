"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => FZF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/junegunn/fzf/issues/337
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l -g ""'
" https://github.com/junegunn/fzf/blob/master/README-VIM.md => Not working
" set rtp+=/opt/homebrew/bin/fzf
set rtp+=/usr/local/opt/fzf

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction


let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

" - down / up / left / right
let g:fzf_layout = { 'down': '40%' }
" Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
"   'previous-history' instead of 'down' and 'up'.
let g:fzf_history_dir = '~/.local/share/fzf-history'

command! -bang -nargs=? Ag call fzf#vim#ag(<q-args>, "--hidden --ignore sorbet/rbi --ignore .git", fzf#vim#with_preview(), <bang>0)

" https://github.com/junegunn/fzf.vim/issues/27#issuecomment-608294881
" "Raw" version of ag; arguments directly passed to ag
"
" e.g.
"   " Search 'foo bar' in ~/projects
"   :Ag "foo bar" ~/projects
"
"   " Start in fullscreen mode
"   :Ag! "foo bar"
" Raw version with preview
command! -bang -nargs=+ -complete=file Agr call fzf#vim#ag_raw(<q-args>, fzf#vim#with_preview(), <bang>0)

" AgIn: Start ag in the specified directory
"
" e.g.
"   :AgIn .. foo
function! s:ag_in(bang, ...)
  if !isdirectory(a:1)
    throw 'not a valid directory: ' .. a:1
  endif
  " Press `?' to enable preview window.
  call fzf#vim#ag(join(a:000[1:], ' '), fzf#vim#with_preview({'dir': a:1}, 'up:50%:hidden', '?'), a:bang)

  " If you don't want preview option, use this
  " call fzf#vim#ag(join(a:000[1:], ' '), {'dir': a:1}, a:bang)
endfunction

command! -bang -nargs=+ -complete=dir AgIn call s:ag_in(<bang>0, <f-args>)
