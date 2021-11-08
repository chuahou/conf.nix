" settings for keybindings and control

" enable mouse in any mode
set mouse=a

" add copy / paste using \y \p by using + (clipboard) as yank/paste register
" check compatibility with :version
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <Leader>P "+P

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

" select pasted area using gp (similar to gv)
nnoremap gp `[v`]

" navigation in command line mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>
	" Thanks to https://github.com/tpope/vim-rsi/issues/15#issuecomment-198632142.
cnoremap <C-d> <Del>
