" vim: set et ts=2:
" Disable coc.nvim.
CocDisable
call clearmatches()
call nvim_buf_clear_namespace(bufnr('%'), -1, 0, -1)
echo "Disabled coc.nvim, loading lsp config"

lua << EOF
require'lspconfig'.clangd.setup {
  handlers = {
    ['textDocument/publishDiagnostics'] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true, virtual_text = false, signs = true
      })
  }
}
EOF
augroup nvim-lsp
  autocmd!
  autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics(
        \{ focusable = false, show_header = false, close_events = {
          \"CursorMoved", "CursorMovedI", "BufHidden", "BufLeave", "InsertCharPre"
        \}})
augroup END
nnoremap ]g <CMD>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap [g <CMD>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap K  <CMD>lua vim.lsp.buf.hover()<CR>
nnoremap gd <CMD>lua vim.lsp.buf.declaration()<CR>
nnoremap gD <CMD>lua vim.lsp.buf.definition()<CR>
nnoremap gi <CMD>lua vim.lsp.buf.implementation()<CR>
nnoremap gr <CMD>lua vim.lsp.buf.references()<CR>
nnoremap gq <CMD>cclose<CR>
nnoremap <expr> <CR> &buftype ==# 'quickfix' ? '<CMD>.cc<CR><CMD>copen<CR>' : '<CR>'

" Diagnostics appearance.
highlight LspDiagnosticsDefaultError   ctermfg=9    ctermbg=none
highlight LspDiagnosticsDefaultWarning ctermfg=11   ctermbg=none
highlight LspDiagnosticsDefaultHint    ctermfg=none ctermbg=none
highlight LspDiagnosticsUnderlineError   cterm=underline
highlight LspDiagnosticsUnderlineWarning cterm=underline
sign define LspDiagnosticsSignError       text=⚠  numhl=LspDiagnosticsDefaultError
sign define LspDiagnosticsSignWarning     text=⚠  numhl=LspDiagnosticsDefaultWarning
sign define LspDiagnosticsSignInformation text=I  numhl=LspDiagnosticsDefaultInformation
sign define LspDiagnosticsSignHint        text=H  numhl=LspDiagnosticsDefaultHint

" Miscellanous.
set cmdheight=2 " More display space.

edit!
echo "Loaded lsp config"
