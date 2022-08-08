" SPDX-License-Identifier: MIT
" Copyright (c) 2022 Chua Hou
"
" Gets current highlight groups under cursor.

function! s:GetHighlight()
	" Syntax ID of character under cursor.
	let l:id = synID(line('.'), col('.'), 1)
	" Get name of syntax ID.
	let l:name = l:id->synIDattr('name')
	" Get name of effective highlight group following highlight links.
	let l:transName =  l:id->synIDtrans()->synIDattr('name')

	echo l:name . ' -> ' . l:transName
endfun

command! GetHighlight call s:GetHighlight()
