" Rex pane navigation, the editor half of a vim-tmux-navigator style round trip.
"
" <C-h/j/k/l> moves between splits; at a split edge it hands off to Rex so focus
" crosses into the neighbouring block. The Rex half lives in ~/.config/rex/init.lua:
" it forwards these keys to the terminal whenever vim is in the foreground.
"
" `rex focus` acts on $REX_BLOCK, the block this editor runs in, not on whatever
" block the app happens to have focused.
"
" Only active in a Rex terminal without tmux in between — inside tmux,
" vim-tmux-navigator's own mappings stay in charge.

if empty($REX_BLOCK) || !empty($TMUX)
  finish
endif

function! s:Navigate(wincmd, dir) abort
  let l:prev = winnr()
  execute 'wincmd ' . a:wincmd
  if winnr() == l:prev
    " No split that way: cross into the Rex block.
    call system('rex focus ' . a:dir)
  endif
endfunction

" fzf's terminal UI binds these itself.
function! s:TermNavigate(key, wincmd, dir) abort
  if &filetype ==# 'fzf'
    return a:key
  endif
  return "\<C-\>\<C-n>:call \<SID>Navigate('" . a:wincmd . "', '" . a:dir . "')\<CR>"
endfunction

" On VimEnter: vim-tmux-navigator's plugin/ file is sourced after the vimrc and
" would map these keys back to TmuxNavigate*.
function! s:Map() abort
  for [l:key, l:dir] in [['h', 'left'], ['j', 'down'], ['k', 'up'], ['l', 'right']]
    execute printf("nnoremap <silent> <C-%s> :call <SID>Navigate('%s', '%s')<CR>", l:key, l:key, l:dir)
    if has('nvim')
      execute printf("tnoremap <expr> <silent> <C-%s> <SID>TermNavigate(\"\\<C-%s>\", '%s', '%s')", l:key, l:key, l:key, l:dir)
    endif
  endfor
endfunction

augroup rex_navigation
  autocmd!
  autocmd VimEnter * call s:Map()
augroup END
