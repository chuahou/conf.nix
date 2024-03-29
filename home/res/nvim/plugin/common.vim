" common shared settings

" turn on undofiles
set undofile

" add indentation settings
set noexpandtab  " use hard tabs
set tabstop=4    " hard tab width of 4
set shiftwidth=0 " sync shiftwidth with tabstop

" auto wrap after 80 columns
set textwidth=80

" ensure new line at EOF
set fixeol

" only save folds with mkview / loadview
set viewoptions=folds

" set wildmenu settings
" complete to longest completion on first <Tab>
set wildmenu
set wildmode=longest:full,full

" only insert single space after punctuation
set nojoinspaces

" Create backup directory by default
if empty(glob('~/.local/share/nvim/backup'))
	silent !mkdir -p ~/.local/share/nvim/backup
endif

" backup directories
set backupdir=~/.local/share/nvim/backup//,.
set directory=~/.local/share/nvim/backup//,.
set undodir=~/.local/share/nvim/backup//,.

" remove empty lines at end of file
function s:TrimEndLines()
	let save_cursor = getpos(".")
	silent! %s#\($\n\s*\)\+\%$##
	call setpos('.', save_cursor)
endfunction

" runs cmd if file exists in pwd
function s:MaybeRun(cmd, file)
	if executable(a:cmd)
		if filereadable(a:file)
			call jobstart(a:cmd)
		endif
	endif
endfunction

augroup commonautocmd
	" clear existing
	autocmd!

	" remember last position when opening file
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
				\ exe "normal! g'\"" | endif

	" remove empty lines on write
	autocmd BufWritePre * call s:TrimEndLines()

	" run hpack upon package.yaml written silently
	autocmd BufWritePost package.yaml silent exec "call s:MaybeRun('hpack', 'package.yaml')"

	" load and save folds automatically
	" https://vi.stackexchange.com/a/13874
	autocmd BufWinLeave,BufLeave,BufWritePost ?* nested silent! mkview!
	autocmd BufWinEnter ?* silent! loadview

	" set nix ft for .nix files
	autocmd BufRead,BufNewFile *.nix set filetype=nix

	" set dockerfile ft for Containerfiles
	autocmd BufRead,BufNewFile *.containerfile set filetype=dockerfile
	autocmd BufRead,BufNewFile Containerfile set filetype=dockerfile
augroup END
