" vim-airline theme matching Rex's merino-dark (GitHub Dark Default). .vimrc picks it
" (g:airline_theme = 'rex') inside Rex.
"
" Each section is [guifg, guibg, ctermfg, ctermbg(, attrs)].

let s:bg      = '#0d1117'
let s:surface = '#161b22'
let s:muted   = '#30363d'
let s:fg      = '#e6edf3'
let s:subtle  = '#8b949e'

function! s:mode(accent) abort
  return airline#themes#generate_color_map(
        \ [s:bg, a:accent, 0, 4, 'bold'],
        \ [s:fg, s:muted, 15, 8, ''],
        \ [s:subtle, s:surface, 7, 0, ''])
endfunction

let g:airline#themes#rex#palette = {}
let g:airline#themes#rex#palette.normal  = s:mode('#58a6ff')
let g:airline#themes#rex#palette.insert  = s:mode('#3fb950')
let g:airline#themes#rex#palette.visual  = s:mode('#bc8cff')
let g:airline#themes#rex#palette.replace = s:mode('#ff7b72')
let g:airline#themes#rex#palette.commandline = s:mode('#d29922')
let g:airline#themes#rex#palette.terminal = s:mode('#39c5cf')
let g:airline#themes#rex#palette.inactive = airline#themes#generate_color_map(
      \ [s:subtle, s:surface, 7, 0, ''],
      \ [s:subtle, s:surface, 7, 0, ''],
      \ [s:subtle, s:bg, 7, 0, ''])

" Whitespace/coc warnings and errors as coloured text on the bar, not solid blocks.
let s:warning = ['#d29922', s:surface, 3, 0, 'bold']
let s:error   = ['#ff7b72', s:surface, 1, 0, 'bold']
for s:m in ['normal', 'insert', 'visual', 'replace', 'commandline', 'terminal']
  let g:airline#themes#rex#palette[s:m].airline_warning = s:warning
  let g:airline#themes#rex#palette[s:m].airline_error = s:error
  let g:airline#themes#rex#palette[s:m . '_modified'] = { 'airline_c': [s:fg, s:surface, 15, 0, ''] }
endfor
