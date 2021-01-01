" enables default nvim behaviour in normal vim

if !has('nvim')
	" show trailing whitespace
	set lcs=trail:+

	" mouse
	set ttymouse=xterm2

	" enable statusline and ruler
	set laststatus=2
	set ruler

	" highlight searches
	set hlsearch
	set incsearch

	" indentation
	filetype plugin indent on
	set autoindent
	set smarttab

	" matchit plugin is enabled by default in neovim
	runtime macros/matchit.vim

	" loads of other stuff from https://neovim.io/doc/user/vim_diff.html
	set autoread                   " reread file if modified externally
	set backspace=indent,eol,start " enable backspace over whitespace
	set belloff=all                " no ringing bell please
	set cscopeverbose              " no clue
	set display=lastline           " display settings
	set encoding=utf-8             " default encoding utf-8
	set formatoptions=tcqj         " will be overwritten by ftdetect
	set nofsync                    " don't call OS fsync for efficiency
	set history=10000              " max history
	set langnoremap                " some map shenanigans
	set nolangremap                " langnoremap but better
	set nrformats=bin,hex          " number formats for C-A, C-X
	set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
	set shortmess=filnxtToOFc
	set showcmd                    " show partial command
	set sidescroll=1               " horizontal scroll unit
	set nostartofline              " don't jump to start of line when switching
	set tabpagemax=50              " maximum number of tabs
	set tags=./tags;,tags          " filenames for tag command
	set ttimeoutlen=50             " timeout length for commands
	set ttyfast
	set wildmenu                   " completion menu
endif
