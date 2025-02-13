"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:which_key_map.g = {
      \   'name':  '+go/git',
      \   'ap':    'git-add-patch-current-file',
      \   'cf':    'git-changed-files-from-main',
      \   'cgp':   'go-copy-path',
      \   't':     'go-view-translate',
      \   'cu':    'git-copy-url',
      \   'ccu':   'git-copy-class-url',
      \   'cmu':   'git-copy-method-url',
      \   'cwu':   'git-copy-word-url',
      \   'bl':    'git-blame',
      \   'br':    'git-browse',
      \   'brc':   'git-browse-current',
      \   'bpr':   'git-browse-pull-requst',
      \   'lf':    'git-log-file',
      \   'll':    'git-log-line',
      \   'lo':     'git-log',
      \   'lm':    'git-log-method',
      \   'd':     'git-diff',
      \   'dh':    'git-diff-left',
      \   'dl':    'git-diff-right',
      \ }
let g:gitgutter_preview_win_location='bel'
let g:gitgutter_update_interval = 1000
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nnoremap <leader>gcu :let @" = execute('.GBrowse!')<CR>:OSCYankRegister "<CR>
nnoremap <leader>gccu :call GitCopyClassUrl()<CR>
nnoremap <leader>gcmu :call GitCopyMethodUrl()<CR>
nnoremap <leader>gcwu :call GitCopyWordUrl()<CR>
vnoremap <leader>gcu :GBrowse!<CR>
nnoremap <leader>gbl :Git blame -C -C<CR>
nnoremap <leader>gbL :Git blame -C -C -C<CR>
nnoremap <leader>gbr v:GBrowse<CR>
vnoremap <leader>gbr :GBrowse<CR>
nnoremap <leader>gbc :execute "GBrowse " . expand("<cword>")<cr>
nnoremap <leader>grv :execute "Git revert " . expand("<cword>")<cr>
nnoremap <leader>gbpr :!gh pr view --web<cr>
nnoremap <leader>glo :Gclog<CR>
nnoremap <leader>glf :Git log --follow --oneline --decorate -- %<CR>
nnoremap <leader>gll :execute ":!git log -L " . line(".") . "," . line(".") . ":" . expand("%")<CR>
nnoremap <leader>glm :execute ":!git log -L " . ":" . expand("<cword>") . ":" . expand("%")<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gdb :Gvdiffsplit origin/main
nnoremap <leader>gcf :Git diff --name-only origin/main
nnoremap <leader>gap :Git add --patch %<CR>
nnoremap <leader>gdg :diffget<CR>
nnoremap <leader>gdh :diffget //2<CR>:diffupdate<CR>
nnoremap <leader>gdl :diffget //3<CR>:diffupdate<CR>

function GitCopyClassUrl()
  call YankFQN()
  let @" = "[" . execute('echon trim(@0)') . "](" . trim(execute('.GBrowse!')) . ")"
  call OSCYankRegister('"')
endfunction

function GitCopyMethodUrl()
  call YankFQN()
  normal "cyiw
  let @" = "[" . execute('echon trim(@0)') . "#" . execute('echon trim(@c)') . "](" . trim(execute('.GBrowse!')) . ")"
  call OSCYankRegister('"')
endfunction

function GitCopyWordUrl()
  normal "cyiw
  let @" = "[" . execute('echon trim(@c)') . "](" . trim(execute('.GBrowse!')) . ")"
  call OSCYankRegister('"')
endfunction
