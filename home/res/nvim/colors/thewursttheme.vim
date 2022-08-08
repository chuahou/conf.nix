" Theme by Chua Hou
" thewursttheme

" Based on: Vim colorscheme template file
" https://github.com/ggalindezb/vim_colorscheme_template/blob/master/template.vim

highlight clear
let g:colors_name = "thewursttheme"

" To be set: ctermfg=9\s\+ctermbg=1

" --- General settings

" Editor settings
highlight Normal ctermfg=none  ctermbg=none cterm=none
highlight LineNr ctermfg=Brown ctermbg=none cterm=none

" Column highlights
highlight ColorColumn  ctermfg=none ctermbg=none cterm=none
highlight CursorColumn ctermfg=none ctermbg=none cterm=none
highlight FoldColumn   ctermfg=6    ctermbg=none cterm=reverse
highlight SignColumn   ctermfg=none ctermbg=none cterm=none
highlight Folded       ctermfg=7    ctermbg=none cterm=reverse

" Window/tab delimiters
highlight VertSplit   ctermfg=8    ctermbg=8    cterm=none
highlight TabLine     ctermfg=7    ctermbg=8    cterm=none
highlight TabLineFill ctermfg=none ctermbg=8    cterm=none
highlight TabLineSel  ctermfg=3    ctermbg=none cterm=reverse

" Explorer
highlight Directory ctermfg=4 ctermbg=none cterm=none

" Search
highlight Search    ctermfg=15 ctermbg=none cterm=reverse
highlight IncSearch ctermfg=15 ctermbg=none cterm=reverse

" Prompt/status
highlight StatusLine   ctermfg=10   ctermbg=none cterm=reverse
highlight StatusLineNC ctermfg=2    ctermbg=none cterm=reverse
highlight WildMenu     ctermfg=none ctermbg=none cterm=reverse
highlight Question     ctermfg=2    ctermbg=none cterm=none
highlight Title        ctermfg=5    ctermbg=none cterm=none
highlight ModeMsg      ctermfg=11   ctermbg=none cterm=none
highlight MoreMsg      ctermfg=2    ctermbg=none cterm=none

" Visual aid
highlight MatchParen ctermfg=2  ctermbg=none cterm=reverse
highlight Visual     ctermfg=15 ctermbg=239  cterm=none
highlight VisualNOS  ctermfg=9  ctermbg=none cterm=reverse
highlight NonText    ctermfg=9  ctermbg=none cterm=none

" Messages
highlight ErrorMsg   ctermfg=9    ctermbg=none cterm=underline
highlight WarningMsg ctermfg=1    ctermbg=none cterm=none
highlight SpecialKey ctermfg=15   ctermbg=none cterm=none

" --- Syntax settings

" Misc syntax
highlight Underlined ctermfg=2  ctermbg=none cterm=underline
highlight Ignore     ctermfg=9  ctermbg=1    cterm=none
highlight Todo       ctermfg=15 ctermbg=9    cterm=none
highlight Error      ctermfg=1  ctermbg=none cterm=undercurl

" Variable types
highlight Constant        ctermfg=11 ctermbg=none cterm=none
highlight String          ctermfg=2  ctermbg=none cterm=none
highlight StringDelimiter ctermfg=2  ctermbg=none cterm=none
highlight Character       ctermfg=6  ctermbg=none cterm=none
highlight Number          ctermfg=6  ctermbg=none cterm=none
highlight Boolean         ctermfg=5  ctermbg=none cterm=none
highlight Float           ctermfg=6  ctermbg=none cterm=none
highlight Identifier      ctermfg=3  ctermbg=none cterm=none
highlight Function        ctermfg=1  ctermbg=none cterm=none

" Language constructs
highlight Statement      ctermfg=1    ctermbg=none cterm=none
highlight Conditional    ctermfg=1    ctermbg=none cterm=none
highlight Repeat         ctermfg=1    ctermbg=none cterm=none
highlight Label          ctermfg=9    ctermbg=none cterm=none
highlight Operator       ctermfg=1    ctermbg=none cterm=none
highlight Keyword        ctermfg=3    ctermbg=none cterm=none
highlight Exception      ctermfg=1    ctermbg=none cterm=none
highlight Comment        ctermfg=7    ctermbg=none cterm=none
highlight Special        ctermfg=15   ctermbg=none cterm=none
highlight SpecialChar    ctermfg=10   ctermbg=none cterm=none
highlight Tag            ctermfg=2    ctermbg=none cterm=reverse
highlight Delimiter      ctermfg=none ctermbg=none cterm=none
highlight SpecialComment ctermfg=9    ctermbg=1    cterm=none
highlight Debug          ctermfg=9    ctermbg=1    cterm=none

" C-like
highlight PreProc      ctermfg=5  ctermbg=none cterm=none
highlight Include      ctermfg=5  ctermbg=none cterm=none
highlight Define       ctermfg=5  ctermbg=none cterm=none
highlight Macro        ctermfg=5  ctermbg=none cterm=none
highlight PreCondit    ctermfg=13 ctermbg=none cterm=none
highlight Type         ctermfg=2  ctermbg=none cterm=none
highlight StorageClass ctermfg=3  ctermbg=none cterm=none
highlight Structure    ctermfg=3  ctermbg=none cterm=none
highlight Typedef      ctermfg=3  ctermbg=none cterm=none

" Diff
highlight DiffAdd    ctermfg=2  ctermbg=10 cterm=none
highlight DiffChange ctermfg=4  ctermbg=12 cterm=none
highlight DiffDelete ctermfg=1  ctermbg=9  cterm=none
highlight DiffText   ctermfg=4  ctermbg=12 cterm=underline

" Completion menu
highlight Pmenu      ctermfg=15   ctermbg=0    cterm=none
highlight PmenuSel   ctermfg=4    ctermbg=none cterm=reverse
highlight PmenuSbar  ctermfg=none ctermbg=8    cterm=none
highlight PmenuThumb ctermfg=none ctermbg=7    cterm=none

" Spelling
highlight SpellBad   ctermfg=none ctermbg=none cterm=undercurl
highlight SpellCap   ctermfg=none ctermbg=none cterm=undercurl
highlight SpellLocal ctermfg=9    ctermbg=1    cterm=none
highlight SpellRare  ctermfg=none ctermbg=none cterm=none

" Concealed characters
highlight Conceal ctermfg=3 ctermbg=none cterm=none

" --- For use with vim-markdown

" new groups
highlight WurstMDHide  ctermfg=7  ctermbg=none cterm=italic
highlight WurstMDTitle ctermfg=12 ctermbg=none cterm=none

" link vim-markdown groups to our groups
highlight link htmlTag     WurstMDHide
highlight link htmlTagName WurstMDHide
highlight link htmlEndTag  WurstMDHide
highlight link mkdHeading  WurstMDHide
highlight link htmlH1      WurstMDTitle
highlight link htmlH2      WurstMDTitle
highlight link htmlH3      WurstMDTitle
highlight link htmlH4      WurstMDTitle
highlight link htmlH5      WurstMDTitle
highlight link htmlH6      WurstMDTitle

" --- Specific settings

" 81 line
highlight ColorColumn ctermfg=none ctermbg=Red cterm=none

" slight whitespace highlighting
highlight SpecialKey ctermfg=darkgrey ctermbg=none cterm=none
highlight Whitespace ctermfg=8        ctermbg=none cterm=none
