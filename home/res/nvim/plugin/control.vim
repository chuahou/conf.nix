" settings for keybindings and control

" enable mouse in any mode
set mouse=a

" add copy / paste using \y \p by using + (clipboard) as yank/paste register
" check compatibility with :version
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <Leader>P "+P

" list buffers and insert :b
nnoremap <Leader>b :ls<CR>:b<Space>

" list buffers and insert :bd
nnoremap <Leader>B :ls<CR>:bd<Space>

" open terminal buffer if there already is one, otherwise create one
function OpenTerminal()
	redir @a
	silent exec 'ls'
	redir END

	if getreg('a') =~# "\"term:\/\/"
		exec 'b term'
	else
		exec 'te'
	endif
endfunction
command! TE call OpenTerminal()
nnoremap <Leader>t :TE<CR>
nnoremap <Leader>T <C-w>v<C-w>l:TE<CR>

" transpose
nnoremap <C-t> hxpl

" remove highlighting using C-/, that vim sees as C-_ for some reason
nnoremap <C-_> :noh<CR>

" escape using jj
inoremap jj <Esc>
