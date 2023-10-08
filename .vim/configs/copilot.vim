" Copilot
imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
imap <silent> <C-j> <Plug>(copilot-next)
imap <silent> <C-k> <Plug>(copilot-previous)
imap <silent> <C-h> <Plug>(copilot-dismiss)
