" herdr pane navigation — vendored from the editor side of
" https://github.com/paulbkim-dev/vim-herdr-navigation (MIT, commit 820d48f),
" with the upstream vim.vim's `--current` corrected to `--pane $HERDR_PANE_ID`:
" `--current` resolves to the server's globally focused pane, which is not
" necessarily the one this editor is running in.
"
" <C-h/j/k/l> moves between splits; at a split edge it hands off to herdr so
" focus crosses into the neighbouring pane. The herdr side of the round trip is
" the vim-herdr-navigation plugin (see ~/.config/herdr/config.toml).
"
" Only active inside a herdr pane — outside one, vim-tmux-navigator's own
" mappings stay in charge, so the tmux setup is untouched.

if empty($HERDR_PANE_ID)
  finish
endif

function! s:HerdrFocus(dir) abort
  let l:herdr = empty($HERDR_BIN_PATH) ? 'herdr' : $HERDR_BIN_PATH
  call system(shellescape(l:herdr) . ' pane focus --direction ' . a:dir .
        \ ' --pane ' . shellescape($HERDR_PANE_ID))
endfunction

function! s:Navigate(wincmd, dir) abort
  let l:prev = winnr()
  execute 'wincmd ' . a:wincmd
  if winnr() == l:prev
    " No split that way: cross into the herdr pane.
    call s:HerdrFocus(a:dir)
  endif
endfunction

nnoremap <silent> <C-h> :call <SID>Navigate('h', 'left')<CR>
nnoremap <silent> <C-j> :call <SID>Navigate('j', 'down')<CR>
nnoremap <silent> <C-k> :call <SID>Navigate('k', 'up')<CR>
nnoremap <silent> <C-l> :call <SID>Navigate('l', 'right')<CR>
