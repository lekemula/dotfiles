" Prerequisites:
" 	- nerdtree: For macOS install Vim via `brew install vim` instead of using native one to fix icon brackets issue
" 	- vim-coc: 
" 	  - `brew install node`
" 	- vim-fzf: 
" 	  - `brew install the_silver_searcher`
"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-install vim-plug: https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-repeat'
Plug 'vim-test/vim-test'
Plug 'github/copilot.vim'
Plug 'vim-ruby/vim-ruby'
" Error: "It seems your ruby installation is missing psych"
" Plug 'stefanoverna/vim-i18n'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'chun-yang/auto-pairs'
Plug 'craigemery/vim-autotag'
" Ensure to checkout to release branch manually
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'joom/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'machakann/vim-highlightedyank'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'mg979/vim-visual-multi'
Plug 'kana/vim-textobj-user'
Plug 'ryanoasis/vim-devicons'
Plug 'codegourmet/ruby-yank-fqn'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'sirver/ultisnips'
Plug 'honza/vim-snippets'
Plug 'liuchengxu/vim-which-key'
Plug 'tommcdo/vim-exchange'
Plug 'mattn/emmet-vim'
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'thaerkh/vim-workspace'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'andrewradev/splitjoin.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'vhdirk/vim-cmake'
Plug 'derekwyatt/vim-scala'
Plug 'puremourning/vimspector'
" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"https://vimdoc.sourceforge.net/htmldoc/intro.html#key-notation
autocmd StdinReadPre * let s:std_in=1

" Set leader key
nnoremap <SPACE> <Nop>
let mapleader=" "

:set shell=zsh
:set relativenumber
:set number

" Change page numbers
":nnoremap <C-r>n :set<Space>rnu!<CR>
":nnoremap <C-n> :set<Space>nu!<CR>

" Copy to clipboard after any yank (works even over SSH)
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif

" Cursor change on edit mode
" replace the number after '\e[]'
" Ps = 0  -> blinking block.
" Ps = 1  -> blinking block (default).
" Ps = 2  -> steady block.
" Ps = 3  -> blinking underline.
" Ps = 4  -> steady underline.
" Ps = 5  -> blinking bar (xterm).
" Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Workspace
let g:workspace_autocreate = 1
let g:workspace_session_directory = $HOME . '/.vim/sessions/'
let g:workspace_autosave_always = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text Objects (documentation)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ]m - Go to start of "next method"
" ]M - Go to end of "next method"
" ]] - Go to start of "next module/class"
" ][ - Go to end of "next module/class"
" am - "a method", select from "def" until matching "end"	keyword.
" im - "inner method", select contents of "def"/"end" block,	excluding the "def" and "end" themselves.
" aM - "a class", select from "class" until matching "end" keyword.
" iM - "inner class", select contents of "class"/"end"	block, excluding the "class" and "end" themselves.
" ar - "all ruby block"
" ir - "inner ruby block"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => WhichKey
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
set timeoutlen=500
call which_key#register('<Space>', "g:which_key_map", 'n')
call which_key#register('<Space>', "g:which_key_map_visual", 'v')
let g:which_key_map =  {}
let g:which_key_map_visual =  {}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spelling
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://thoughtbot.com/blog/vim-spell-checking
let g:which_key_map.s = { 'name' : '+spelling' }
:set spelllang=en_us
nnoremap <leader>ss :setlocal spell!<CR>
let g:which_key_map.s.s = 'enable-spelling'
nnoremap <leader>sc :set complete+=kspell<CR>
let g:which_key_map.s.c = 'enable-spell-comletion'
nnoremap <leader>sn :set complete-=kspell<CR>
let g:which_key_map.s.n = 'disable-spell-comletion'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=a
let g:which_key_map.t = { 'name' : '+file-tree' }
nnoremap <leader>tt :NERDTreeToggle<CR>
let g:which_key_map.t.t = 'toggle-file-tree'
nnoremap <leader>tf :NERDTreeFind %<CR>zz
let g:which_key_map.t.f = 'file-tree-find-file'
nnoremap <leader><space> :Buffers<CR>
map ` :Marks<CR>

" Multi Cursor
let g:VM_maps = {}
let g:VM_maps["Add Cursor Down"] = 'Ô' " ALT + J
let g:VM_maps["Add Cursor Up"]   = '' " ALT + K

imap jj <Esc>
nnoremap H ^
nnoremap L $
nnoremap <F5> :source ~/.vimrc<CR>
nnoremap <F12> :edit ~/.vimrc<CR>
nnoremap <leader>fs :Files <CR>
nnoremap g? :execute "!open 'https://www.google.com/search?q=" . expand("<cword>") . "'"<cr>
vnoremap g? y:execute "!open 'https://www.google.com/search?q=" . expand("<C-r>0") . "'"<cr>
" Workaround for URL navigation on Shopify spin remote instance
nnoremap <leader>gx :execute "!open '" . shellescape("<cWORD>") . "'"<cr>
vnoremap <leader>gx y:execute "!open '" . shellescape("<C-r>0") . "'"<cr>
nnoremap <leader>gcp :let @"=join([expand('%'),  line(".")], ':')<CR>:OSCYankRegister "<CR>

let g:which_key_map.c = { 'name' : '+quickfix' }
nnoremap <leader>cc :cc<CR>
let g:which_key_map.c.c = 'fix-current'
nnoremap <leader>cn :cnext<CR>
let g:which_key_map.c.n = 'fix-next'
nnoremap <leader>cp :cprevious<CR>
let g:which_key_map.c.p = 'fix-previous'

" Tests
let test#strategy = "dispatch"
let b:dispatch = ":0Spawn!"
nmap <silent> <leader>TT :let test#strategy = "dispatch"<CR>:TestNearest<CR>
nmap <silent> <leader>TD :let test#strategy = "basic"<CR>:TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>TS :TestSuite<CR>
nmap <silent> <leader>TL :TestLast<CR>
nmap <silent> <leader>TV :TestVisit<CR>

let g:nerdtree_sync_cursorline = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Debugging
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <Leader>dc <Plug>VimspectorContinue
" nmap <Leader>dd <Plug>VimspectorReset
nmap <Leader>ds <Plug>VimspectorStop
nmap <Leader>dr <Plug>VimspectorRestart
nmap <Leader>dd <Plug>VimspectorToggleBreakpoint
nmap <Leader>di <Plug>VimspectorToggleConditionalBreakpoint
nmap <Leader>dj <Plug>VimspectorStepOver
nmap <Leader>dh <Plug>VimspectorStepInto
nmap <Leader>dk <Plug>VimspectorStepOut
nmap <Leader>dt <Plug>VimspectorRunToCursor
nmap <Leader>de :VimspectorEval <C-R><C-W><CR>

nnoremap <leader>dd <Plug>VimspectorToggleBreakpoint
nnoremap <leader>dl <Plug>VimspectorBreakpoints
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Edit
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move lines and selections up/down
" https://super-unix.com/superuser/macos-iterm2-vim-cannot-map-alt-key/
" Alt+j
nnoremap ∆ :m .+1<CR>==
" Alt+k
nnoremap ˚ :m .-2<CR>==
" Alt+j
vnoremap ∆ :m '>+1<CR>gv=gv
" Alt+k
vnoremap ˚ :m '<-2<CR>gv=gv

nmap <leader>' ysiw'
nmap <leader>" ysiw"
vmap <leader>' S'
vmap <leader>" S"

nnoremap <leader>ws :setlocal list!<cr>

" Snippets
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
let g:UltiSnipsSnippetDirectories=["my-snippets", "UltiSnips"]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ruby/Rails
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:let ruby_spellcheck_strings = 1
let g:autotagStartMethod='fork'
let g:rails_ctags_arguments=['-f tmp/tags', '-R', '--exclude=tmp', '--exclude=log', '--exclude=.git','--languages=Ruby', '.', '$(bundle list --paths)']
"ctags -f tmp/tags -R --exclude=tmp --exclude=log --exclude=.git . $(bundle list --paths)
vmap <leader>gt :call I18nTranslateString()<CR>
vmap <leader>dt :call I18nDisplayTranslation()<CR>

" Yank/Copy fully quialified class name to clipboard
let g:yankfqn_register = '"'
nmap <leader>gcc :call YankFQN()<CR>:OSCYankRegister "<CR>

" https://github.com/tpope/vim-rails/issues/503#issuecomment-1158877143
command AC :execute "e " . eval('rails#buffer().alternate()')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Folding
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://stackoverflow.com/a/15087735
setlocal foldmethod=indent
set foldlevel=99
" :set foldmethod=indent
" :let ruby_fold = 0
" set nofoldenable

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Autocompletion
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1
let g:rubycomplete_load_gemfile = 1
let g:rubycomplete_use_bundler = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Splits and Tabbed Files
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set splitbelow splitright

" Tab navigation
nnoremap <C-t>h :tabprevious<CR>
nnoremap <C-t>l :tabnext<CR>
nnoremap <C-t>t :tabnew<CR>
nnoremap <C-t>h <Esc>:tabprevious<CR>
nnoremap <C-t>l <Esc>:tabnext<CR>
nnoremap <C-t>t <Esc>:tabnew<CR>

" Make adjusing split sizes a bit more friendly
noremap <silent> <C-j>j :resize +15<CR>
noremap <silent> <C-k>k :resize -15<CR>
noremap <silent> <C-l>l :vertical resize +15<CR>
noremap <silent> <C-h>h :vertical resize -15<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Appearance
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
" Set theme
colorscheme gruvbox
set background=dark
let NERDTreeShowHidden=1
let g:webdevicons_conceal_nerdtree_brackets=1
:set colorcolumn=120
" Indentation
filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2

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
nnoremap <leader>gcu :let @" = execute('.GBrowse!')<CR>:OSCYankRegister "<CR>
nnoremap <leader>gbl :Git blame<CR>
nnoremap <leader>gbr v:GBrowse<CR>
vnoremap <leader>gbr :GBrowse<CR>
nnoremap <leader>gbc :execute "GBrowse " . expand("<cword>")<cr>
nnoremap <leader>gbpr :!gh pr view --web<cr>
nnoremap <leader>glf :Git log --oneline --decorate --graph -- %<CR>
nnoremap <leader>gll :execute ":!git log -L " . line(".") . "," . line(".") . ":" . expand("%")<CR>
nnoremap <leader>glm :execute ":!git log -L " . ":" . expand("<cword>") . ":" . expand("%")<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gdb :Gvdiffsplit origin/main<CR>
nnoremap <leader>gdg :diffget<CR>
nnoremap <leader>gdh :diffget //2<CR>
nnoremap <leader>gdl :diffget //3<CR>

" Copilot
imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
imap <silent> <C-j> <Plug>(copilot-next)
imap <silent> <C-k> <Plug>(copilot-previous)
imap <silent> <C-h> <Plug>(copilot-dismiss)

    
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => COC
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-css', 'coc-html', 'coc-docker', 'coc-eslint', 'coc-snippets', 'coc-sql', 'coc-yank', 'coc-tsserver', 'coc-metals', 'coc-clangd']
" https://github.com/neoclide/coc.nvim#example-vim-configuration
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=1000

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gtd <Plug>(coc-type-definition)
nmap <silent> gim <Plug>(coc-implementation)
nmap <silent> grf <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Formatting current file
nmap <leader>fd  :CocCommand editor.action.formatDocument<CR>

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>.  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>e  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>ex  :<C-u>CocList extensions<cr>
" Show commands.
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>sy  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" END OF COC configs

" Pathogen plugins
inoremap <C-p>r <C-r>=system('ls ~/.vim/bundle')<cr>

" execute pathogen#infect()
syntax enable
set encoding=UTF-8
let g:airline_powerline_fonts = 1
filetype plugin indent on
set autoindent
set cindent
set smartindent
set omnifunc=syntaxcomplete#Complete
" after a re-source, fix syntax matching issues (concealing brackets):
" https://github.com/ryanoasis/vim-devicons/issues/154#issuecomment-222032236
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif
