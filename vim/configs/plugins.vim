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

" Vim-only Plugins
if !has('nvim')
" TODO Review ChatGPT suggested vim-only plugins and find replacements for neovim
"   Plug 'tpope/vim-sensible'
"   Plug 'vim-airline/vim-airline'
"   Plug 'vim-airline/vim-airline-themes'
"   Plug 'vim-scripts/matchit.zip'
"   Plug 'airblade/vim-gitgutter'
"   Plug 'chun-yang/auto-pairs'
"   Plug 'liuchengxu/vim-which-key'
"   Plug 'michaeljsmith/vim-indent-object'
"   Plug 'konfekt/fastfold'
"   Plug 'Yggdroot/indentLine'
"   Plug 'terryma/vim-expand-region'
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  " fastfold messes up with avante in neovim
  Plug 'konfekt/fastfold'
  " copilot.lua is used for neovim
  Plug 'github/copilot.vim'
  " test autocompletion 
endif

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'j-hui/fidget.nvim' " LSP progress
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  " Avante Deps
  " Plug 'nvim-lua/plenary.nvim'
  Plug 'MunifTanjim/nui.nvim'
  Plug 'MeanderingProgrammer/render-markdown.nvim'
  Plug 'stevearc/dressing.nvim' " for enhanced input UI
  Plug 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make' }
  Plug 'zbirenbaum/copilot.lua'
endif

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
Plug 'tpope/vim-cucumber'
Plug 'tpope/vim-liquid'
" Manage databases
Plug 'tpope/vim-dadbod'
" :Mkdir, :Rename, :Delete, :Move
Plug 'tpope/vim-eunuch'
" Coerce between snake_case, camelCase, and kebab-case: crs, crc, crk
Plug 'tpope/vim-abolish'
" Manage databases UI
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'
" http://vimcasts.org/episodes/aligning-text-with-tabular-vim/
Plug 'godlygeek/tabular'
Plug 'vim-test/vim-test'
Plug 'vim-ruby/vim-ruby'
Plug 'ngmy/vim-rubocop'
Plug 'vim-scripts/matchit.zip'
Plug 'ecomba/vim-ruby-refactoring'
" Error: "It seems your ruby installation is missing psych"
" Plug 'stefanoverna/vim-i18n'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'chun-yang/auto-pairs'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'sainnhe/gruvbox-material', {'branch': 'master'}
Plug 'joom/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'machakann/vim-highlightedyank'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'mg979/vim-visual-multi'
Plug 'kana/vim-textobj-user'
Plug 'ryanoasis/vim-devicons'
Plug 'codegourmet/ruby-yank-fqn'
Plug 'preservim/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'honza/vim-snippets'
Plug 'liuchengxu/vim-which-key'
" Exchange 2 words using:  cx (as change eXchange)
" http://vimcasts.org/episodes/swapping-two-regions-of-text-with-exchange-vim/
Plug 'tommcdo/vim-exchange'
" HTML tags completion
" Example: ul#my-id>li*3.my-class<C-y>,
" https://raw.githubusercontent.com/mattn/emmet-vim/master/TUTORIAL
Plug 'mattn/emmet-vim'
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'thaerkh/vim-workspace'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'andrewradev/splitjoin.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'vhdirk/vim-cmake'
Plug 'derekwyatt/vim-scala'
Plug 'puremourning/vimspector'
Plug 'christoomey/vim-tmux-navigator'
Plug 'hashivim/vim-terraform'
" Text Objects
Plug 'michaeljsmith/vim-indent-object'
Plug 'kana/vim-textobj-entire'
Plug 'vim-scripts/argtextobj.vim'
" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
Plug 'pedrohdz/vim-yaml-folds'
" https://stackoverflow.com/a/15087735
Plug 'towolf/vim-helm'
Plug 'Yggdroot/indentLine'
Plug 'terryma/vim-expand-region'
Plug 'psliwka/vim-smoothie'
Plug 'wellle/context.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'AndrewRadev/switch.vim'
" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
