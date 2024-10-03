"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:which_key_map.g = {
      \   'name': '+go/git',
      \   'cgp':  'go-copy-path',
      \   't':    'go-view-translate',
      \   'cu':   'git-copy-url',
      \   'bl':   'git-blame',
      \   'br':   'git-browse',
      \   'brc':  'git-browse-current',
      \   'bpr':  'git-browse-pull-requst',
      \   'lf':   'git-log-file',
      \   'll':   'git-log-line',
      \   'lm':   'git-log-method',
      \   'd':    'git-diff',
      \   'dh':   'git-diff-left',
      \   'dl':   'git-diff-right',
      \ }
let g:gitgutter_preview_win_location='bel'
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nnoremap <leader>gcu :let @" = execute('.GBrowse!')<CR>:OSCYankRegister "<CR>
vnoremap <leader>gcu :GBrowse!<CR>
nnoremap <leader>gbl :Git blame -C -C<CR>
nnoremap <leader>gbL :Git blame -C -C -C<CR>
nnoremap <leader>gbr v:GBrowse<CR>
vnoremap <leader>gbr :GBrowse<CR>
nnoremap <leader>gbc :execute "GBrowse " . expand("<cword>")<cr>
nnoremap <leader>grv :execute "Git revert " . expand("<cword>")<cr>
nnoremap <leader>gbpr :!gh pr view --web<cr>
nnoremap <leader>glf :Git log --follow --oneline --decorate -- %<CR>
nnoremap <leader>gll :execute ":!git log -L " . line(".") . "," . line(".") . ":" . expand("%")<CR>
nnoremap <leader>glm :execute ":!git log -L " . ":" . expand("<cword>") . ":" . expand("%")<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gdb :Gvdiffsplit origin/main<CR>
nnoremap <leader>gdg :diffget<CR>
nnoremap <leader>gdh :diffget //2<CR>:diffupdate<CR>
nnoremap <leader>gdl :diffget //3<CR>:diffupdate<CR>
