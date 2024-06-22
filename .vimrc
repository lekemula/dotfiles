" Prerequisites:
" 	- nerdtree: For macOS install Vim via `brew install vim` instead of using native one to fix icon brackets issue
" 	- vim-coc: 
" 	  - `brew install node`
" 	- vim-fzf: 
" 	  - `brew install the_silver_searcher`
"

source ~/vim/configs/plugins.vim
source ~/vim/setcolors.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"https://vimdoc.sourceforge.net/htmldoc/intro.html#key-notation
autocmd StdinReadPre * let s:std_in=0
autocmd VimLeave * NERDTreeClose | NERDTreeClose
autocmd BufNewFile,BufRead *.erb set filetype=eruby.html
" https://github.com/tpope/vim-liquid/blob/fd2f0017fbc50f214db2f57c207c34cda3aa1522/syntax/liquid.vim#L34C3-L34C49
autocmd BufNewFile,BufRead *.liquid.erb let b:liquid_subtype='eruby' | set syntax=liquid

if filereadable(expand("./.vim/.vimrc"))
  source ./.vim/.vimrc
endif

" Fix paste indentation
set pastetoggle=<F2>

" Set leader key
nnoremap <SPACE> <Nop>
let mapleader=" "

set shell=zsh
" Toggle relative line numbers
nnoremap <leader>ln :set relativenumber!<CR>
set norelativenumber
set number
" https://github.com/prabirshrestha/vim-lsp/issues/786
set re=0

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
" Manual Autosave config
let g:workspace_autosave = 0
set noswapfile
au BufLeave * if(getbufinfo('%')[0].changed) | do BufWritePre | sil! up | do BufWritePost | endif

" Pettier Formatting
let g:prettier#autoformat = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""e
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
" hover over a word and press `z=` for spell suggestions
let g:which_key_map.s = { 'name' : '+spelling' }
:set spelllang=en_us
:set spell
:set complete+=kspell
nnoremap <leader>ss :setlocal spell!<CR>
let g:which_key_map.s.s = 'enable-spelling'
nnoremap <leader>sc :set complete+=kspell<CR>
let g:which_key_map.s.c = 'enable-spell-completion'
nnoremap <leader>sn :set complete-=kspell<CR>
let g:which_key_map.s.n = 'disable-spell-completion'
nnoremap <leader>sp z=
let g:which_key_map.s.p = 'spell-suggestions'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=a
let g:which_key_map.t = { 'name' : '+file-tree' }
nnoremap <leader>tt :NERDTreeToggle<CR>
let g:which_key_map.t.t = 'toggle-file-tree'
nnoremap <leader>td :DBUIToggle<CR>
let g:which_key_map.t.d = 'toggle-dbui'
nnoremap <leader>tf :NERDTreeFind %<CR>zz
let g:which_key_map.t.f = 'file-tree-find-file'
nnoremap <leader><space> :Buffers<CR>
let g:which_key_map.l = { 'name' : '+last' }
let g:which_key_map.l.l = 'go-to-last-file'
nnoremap <leader>ll :e #<CR>
" Delete all buffers except the current one
nnoremap <leader>bd :%bd\|e#<CR>

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
" Go copy path
nnoremap <leader>gcp :let @"=join([expand('%'),  line(".")], ':')<CR>:OSCYankRegister "<CR>
let g:which_key_map.s =
  \ {
  \   'name' : '+search/spell',
  \   'iw' : 'inner-word',
  \   'iW' : 'inner-WORD',
  \   'd' : 'method-definition',
  \   'D' : 'method-definition-WORD',
  \   'c' : 'class-definition',
  \   'f' : 'factory-definition',
  \   't' : 'method-test',
  \   'e' : 'rspec-shared-example',
  \   'ssr' : 'service-response'
  \ }
vnoremap <leader>s y:execute ":Ag " . shellescape("<C-r>0") . "" <cr>
nnoremap <leader>siw :execute ":Ag " . expand("<cword>") . "" <cr>
nnoremap <leader>siW :execute ":Ag " . expand("<cWORD>") . "" <cr>
nnoremap <leader>sd :execute ":Ag (def\|attribute\|field\|attr_reader\|attr_accessor) (self\.)?(:\w+,\s)*(:)?" . expand("<cword>") . "" <cr>
nnoremap <leader>sD :execute ":Ag (def\|attribute\|field\|attr_reader\|attr_accessor) (self\.)?(:\w+,\s)*(:)?" . expand("<cWORD>") . "" <cr>

nnoremap <leader>sc :execute ":Ag (class\|module) (.*::)*" . expand("<cword>") . "([^a-zA-Z0-9_\\n]\|\$)" <CR>
nnoremap <leader>sf :execute ":Ag factory :" . expand("<cword>") . "" <cr>
" https://github.com/collectiveidea/interactor gem
nnoremap <leader>st :execute ":AgIn spec/ (describe\|context).*" . expand("<cword>") . "" <cr>
nnoremap <leader>se :execute ":AgIn spec/ shared_example.*" . expand("<cword>") . "" <cr>

" Options: |, ¦, ┆, ┊
let g:indentLine_char = '¦'
let g:indentLine_enabled = 0 " Disable by default
nnoremap <leader>ii :IndentLinesToggle<CR>

" Expand visual selection up
call expand_region#custom_text_objects('ruby', {
      \ 'ir' :0,
      \ 'ar' :0,
      \ 'im' :0,
      \ 'am' :0,
      \ })
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix list
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" https://www.reddit.com/r/vim/comments/i9eka7/comment/g1f0f8j/?utm_source=share&utm_medium=web2x&context=3
" Allow adding list of files in quickfix eg. cexpr system('find "./spec/**/*_spec.rb')
set errorformat+=%f

let g:which_key_map.c = { 'name' : '+quickfix' }
nnoremap <leader>cc :cc<CR>
let g:which_key_map.c.c = 'fix-current'
nnoremap <leader>cn :cnext<CR>
let g:which_key_map.c.n = 'fix-next'
nnoremap <leader>cp :cprevious<CR>
let g:which_key_map.c.p = 'fix-previous'
nnoremap <leader>cs :call LM_ChangedSpecs()<CR>
let g:which_key_map.c.s = 'fix-git-changed-specs'
nnoremap <leader>cf :call LM_ChangedFiles()<CR>
let g:which_key_map.c.f = 'fix-git-changed-files'
nnoremap <leader>cs :cexpr system('find folder/**/*_files.rb')
let g:which_key_map.c.s = 'fix-search-files'
nnoremap <leader>cr :cexpr system("rubocop --format emacs")
let g:which_key_map.c.r = 'fix-rubocop'

function! LM_RuboCopAll()
  cexpr system("rubocop --format emacs")
endfunction

function! LM_ChangedSpecs()
  cexpr system("git status -s | awk '{ print $2  }' | grep spec")
endfunction

function! LM_ChangedFiles()
  cexpr system("git status -s | awk '{ print $2  }'")
endfunction

" Tests
let test#strategy = "dispatch"
let b:dispatch = ":0Spawn!"
let g:test#ruby#rspec#executable = 'bundle exec rspec'
nmap <silent> <leader>TT :let test#strategy = "dispatch"<CR>:TestNearest 2>./tmp/test_errors.txt<CR>
nmap <silent> <leader>TD :let test#strategy = "basic"<CR>:TestNearest 2>./tmp/test_errors.txt<CR>
nmap <silent> <leader>T :TestFile 2>./tmp/test_errors.txt<CR>
nmap <silent> <leader>TS :TestSuite 2>./tmp/test_errors.txt<CR>
nmap <silent> <leader>TL :TestLast 2>./tmp/test_errors.txt<CR>
nmap <silent> <leader>TV :TestVisit 2>./tmp/test_errors.txt<CR>

let g:nerdtree_sync_cursorline = 1

" Project based projections are added in:
"   - gems: lib/projections.json
"   - rails: config/projections.json
let g:projectionist_heuristics = {
\  "*": {
\    "include/*.h": {
\      "alternate": ["src/{}.cpp", "source/{}.cpp"],
\      "related": ["test/source/{}.cpp"],
\      "type": "header"
\    },
\    "src/*.cpp": {
\      "alternate": "include/{}.h",
\      "related": ["test/source/{}.cpp"],
\      "type": "source"
\    },
\    "source/*.cpp": {
\      "alternate": "include/{}.h",
\      "related": ["test/source/{}.cpp"],
\      "type": "source"
\    },
\    "test/source/*.cpp": {
\      "alternate": ["src/{}.cpp", "source/{}.cpp"],
\      "type": "test"
\    },
\    "src/*.component.ts": {
\      "alternate": "src/{}.component.html",
\      "type": "source"
\    },
\    "src/*.component.html": {
\      "alternate": "src/{}.component.ts",
\      "type": "source"
\    },
\  }
\}

" Markdown
" autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:mkdp_auto_start = 0
let g:vim_markdown_new_list_item_indent = 2
set conceallevel=2 " for hiding links when not in insert mode
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_math = 1
let g:vim_markdown_strikethrough = 1

nnoremap <leader>mp <Plug>MarkdownPreviewToggle

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Debugging
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimspector_install_gadgets = ['CodeLLDB']
let g:vimspector_configurations = {
\   "configurations": {
\     "ruby - launch current file": {
\       "filetypes": ["ruby"],
\       "adapter": "cust_vscode-ruby",
\       "configuration": {
\         "request": "launch",
\         "program": "${file}",
\         "args": [ "*${args}"  ]
\       }
\     }
\   }
\ }

nmap <Leader>dc <Plug>VimspectorContinue
nmap <Leader>dq :VimspectorReset<CR>
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

" Fast paste from clipboard
" https://stackoverflow.com/questions/501332/why-is-pasting-a-long-one-liner-very-slow-in-vims-insert-mode
nnoremap <Leader>p :read !pbpaste<CR>

" Replace
nmap <leader>R :%s/
nmap <leader>' ysiw'
nmap <leader>" ysiw"
vmap <leader>' S'
vmap <leader>" S"

nnoremap <leader>ws :setlocal list!<cr>

" Snippets
imap <tab> <Plug>(coc-snippets-expand)
" imap <C-s> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
inoremap <expr> <TAB> pumvisible() ? "\<C-y>" : "\<TAB>"
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ruby/Rails
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:let ruby_spellcheck_strings = 1
let g:autotagStartMethod='fork'
let g:rails_ctags_arguments=['-f tmp/tags', '-R', '--exclude=tmp', '--exclude=log', '--exclude=.git','--languages=Ruby', ' . ', '$(bundle list --paths)']
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
autocmd BufNewFile,BufRead * set foldmethod=indent " syntax causes performance issues!

set foldlevel=99
set foldmethod=indent
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
nnoremap <C-t>q <Esc>:tabclose<CR>

" Make adjusing split ssdizes a bit more friendly
noremap <silent> <C-r>j :resize +15<CR>
noremap <silent> <C-r>k :resize -15<CR>
noremap <silent> <C-r>h :vertical resize +15<CR>
noremap <silent> <C-r>l :vertical resize -15<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Appearance
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
" Set theme
" Important!!
if has('termguicolors')
  set termguicolors
endif

set background=light
set cursorline " Highlight current line

" Set contrast.
" This configuration option should be placed before `colorscheme gruvbox-material`.
" Available values: 'hard', 'medium'(default), 'soft'
let g:gruvbox_material_background = 'medium'
let g:gruvbox_material_foreground = 'material'
let g:gruvbox_material_transparent_background = 0
let g:gruvbox_material_disable_italic_comment = 1
let g:gruvbox_material_enable_bold = 1

" For better performance
let g:gruvbox_material_better_performance = 1

colorscheme gruvbox-material
let g:airline_theme = 'gruvbox_material'
" let g:gruvbox_transparent_bg = 0
" autocmd VimEnter * hi Normal ctermbg=none
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
autocmd FileType markdown setlocal shiftwidth=2
autocmd FileType markdown setlocal tabstop=2
autocmd FileType markdown setlocal softtabstop=2
    
source ~/vim/configs/copilot.vim
source ~/vim/configs/git.vim
source ~/vim/configs/fzf.vim
source ~/vim/configs/coc.vim

" Pathogen plugins
inoremap <C-p>r <C-r>=system('ls ~/.vim/bundle')<cr>

" execute pathogen#infect()
syntax enable
set encoding=UTF-8
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#displayed_head_limit = 10
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
  autocmd bufwritepost ~/.vim/configs/plugins.vim source $MYVIMRC
endif
