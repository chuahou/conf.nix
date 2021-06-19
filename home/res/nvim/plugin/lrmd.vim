" SPDX-License-Identifier: MIT
" Copyright (c) 2021 Chua Hou
"
" Runs pandoc on file write and livereload for instant preview for markdown
" files. (Should technically work for any pandoc input formats.)

" Starts functionality. Sets autocommands and starts livereload, as well as
" opens the browser.
function s:LivereloadMarkdownStart()
	call s:LivereloadMarkdownStop()

	" Call pandoc when file written to.
	let g:lrmd_watched_filename = @%
	augroup livereload_markdown
		au!
		autocmd BufWritePost * if @% == g:lrmd_watched_filename |
					\ exec 'LivereloadMarkdownRunPandoc'
		autocmd BufUnload * if @% == g:lrmd_watched_filename |
					\ exec 'LivereloadMarkdownStop'
	augroup END

	" Start livereload if executable, otherwise start livereload in nix-shell.
	let l:livereload_cmd = "livereload " . expand('%:r') . ".html"
	if !executable('livereload') && executable('nix-shell')
		let l:livereload_cmd = "nix-shell -p python3Packages.livereload --run '"
					\ . l:livereload_cmd . "'"
	endif
	let l:jobid = jobstart(l:livereload_cmd)
	if l:jobid > 0
		let g:lrmd_jobid = l:jobid " Save job ID if successful to stop later.
	endif

	" Open livereload URL.
	call s:LivereloadMarkdownRunPandoc()
	call jobstart("xdg-open http://localhost:35729 & disown")
	echo "If connection failed, refresh after a second."
endfunction

" Runs pandoc once (to be run after writing).
function s:LivereloadMarkdownRunPandoc()
	" Use pandoc if executable, otherwise use pandoc in nix-shell.
	let l:css = split(glob('*.css'))
	if len(l:css) > 0
		let l:css = " -c " . l:css[0]
	else
		let l:css = ""
	endif
	let l:pandoc_cmd = "pandoc " . @% . " -o " . expand('%:r') . ".html"
				\ . l:css . " -s --self-contained"
	if !executable('pandoc') && executable('nix-shell')
		let l:pandoc_cmd = "nix-shell -p pandoc --run '"
					\ . l:pandoc_cmd . "'"
	endif

	call jobstart(l:pandoc_cmd)
endfunction

" Stop running functionality. Idempotent.
function s:LivereloadMarkdownStop()
	" Unset autocommands.
	augroup livereload_markdown
		au!
	augroup END

	" If previously running livereload job, stop it.
	if exists("g:lrmd_jobid")
		call jobstop(g:lrmd_jobid)
		unlet g:lrmd_jobid
	endif
endfunction

" Expose functions as commands.
command! LivereloadMarkdownStart call s:LivereloadMarkdownStart()
command! LivereloadMarkdownRunPandoc call s:LivereloadMarkdownRunPandoc()
command! LivereloadMarkdownStop call s:LivereloadMarkdownStop()

" Stop plugin's functionality if currently running (e.g. if sourcing plugin
" multiple times).
call s:LivereloadMarkdownStop()
