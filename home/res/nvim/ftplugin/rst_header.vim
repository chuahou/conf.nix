" https://github.com/thinca/vim-ft-rst_header/
" Header making support for reStructuredText(rst).
" Version: 0.1.0
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>
"
" Usage:
" To make or modify a header:
"   <LocalLeader>h{level} ({level} is a number key of level.)
" 

if !exists('g:rst_header_chars')
  let g:rst_header_chars = '#*=-^'
endif

nnoremap <silent> <buffer> <Plug>(rst-header) <Nop>
inoremap <silent> <buffer> <Plug>(rst-header) <Nop>
for s:i in range(len(g:rst_header_chars))
  execute 'nnoremap <silent> <buffer> <Plug>(rst-header)' . (s:i + 1) .
  \       ' :<C-u>call <SID>add_header(' . s:i . ')<CR>'
  execute 'inoremap <silent> <buffer> <Plug>(rst-header)' . (s:i + 1) .
  \       ' <ESC>:<C-u>call <SID>add_header(' . s:i . ')<CR>a'
endfor

silent! nmap <unique> <buffer> <LocalLeader>h <Plug>(rst-header)

" FIXME: Add b:undo_ftplugin.

if exists('s:loaded')
  finish
endif

function! s:add_header(level)
  let c = (exists('b:rst_header_chars') ? b:rst_header_chars
  \                                     : g:rst_header_chars)
  let line = repeat(c[a:level], virtcol('$') - 1)
  if empty(line)
    return
  endif
  let cursor = getpos('.')
  let c = escape(c, '-\')

  if getline(line('.') + 1) =~ '^\([' . c . ']\)\1*$'
    .+1 delete _
    call setpos('.', cursor)
  endif
  put = line
  -1

  if getline(line('.') - 1) =~ '^\([' . c . ']\)\1*$'
    .-1 delete _
    let cursor[1] -= 1
  endif
  if a:level < 2
    let cursor[1] += 1
    .-1 put = line
  endif
  call setpos('.', cursor)
endfunction

let s:loaded = 1
