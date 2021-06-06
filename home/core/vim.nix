# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

let
  configLocation = "nvim/copied";
  configDir = "${config.xdg.configHome}/${configLocation}";
in {
  # copy entire nvim configuration directory
  xdg.configFile.${configLocation}.source = ../res/nvim;

  # copy editorconfig
  home.file.".editorconfig".source = ../res/editorconfig;

  programs.neovim = {
    enable = true;

    extraConfig = ''
      " faster updates for coc/vim-gitgutter etc
      set updatetime=100

      " we use the full configuration copied
      set runtimepath^=${configDir} runtimepath+=${configDir}/after
      source ${configDir}/init.vim

      "-------------"
      " vim-airline "
      "-------------"
      let g:airline_theme = 'angr'
      let g:airline#extensions#whitespace#mixed_indent_algo = 1
      let g:airline#extensions#checks = [
        \ 'indent', 'long', 'trailing', 'mixed-indent-file', 'conflicts' ]
      let g:airline#extensions#whitespace#skip_indent_check_ft = {
        \ 'vim': ['trailing'],
        \ }

      " custom symbols for vim-airline
      if !exists('g:airline_symbols')
        let g:airline_symbols = {}
      endif
      let g:airline_symbols.maxlinenr = ' ln'

      "----------"
      " coc.nvim "
      "----------"

      " original example at
      " https://github.com/neoclide/coc.nvim#example-vim-configuration

      " more space to display
      set cmdheight=2

      " trigger completion with <C-space>
      inoremap <silent><expr> <C-space> coc#refresh()

      " activate actions with <C-space>
      nmap <C-space> :CocAction<CR>

      " diagnostics navigation
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " code navigation
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " use K to show documentation in preview window
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
          call CocActionAsync('doHover')
        else
          execute '!' . &keywordprg . " " . expand('<cword>')
        endif
      endfunction

      " add instantRst to path for InstantRst plugin
      let $PATH .= ':' . '${pkgs.instantRstPy}/bin'

      " use smdv in vim-instant-markdown
      let $PATH .= ':' . '${pkgs.smdv}/bin'
      let g:instant_markdown_python = 1
      let g:instant_markdown_autostart = 0 " manual startup

      "--------"
      " vimtex "
      "--------"

      " use LaTeX flavour by default
      let g:tex_flavor = 'latex'

      " disable alignment of ampersands
      let g:vimtex_indent_on_ampersands = 0

      " disable imaps mappings since ` is used often
      let g:vimtex_imaps_enabled = 0

      "-------------------"
      " vim-pandoc-syntax "
      "-------------------"

      " load vim-pandoc-syntax
      augroup pandoc_syntax
        au! BufNewFile,BufFilePre,BufRead *.md set ft=markdown.pandoc
      augroup END

      " don't conceal
      let g:pandoc#syntax#conceal#use = 0
    '';

    plugins = with pkgs.vimPlugins; [
      # language plugins
      pkgs.coc-nvim
      pkgs.coc-clangd
      haskell-vim
      vim-nix
      vimtex
      vim-pandoc-syntax
      purescript-vim

      # alignment
      tabular

      # vim-airline
      vim-airline
      vim-airline-themes

      # git sign column
      vim-gitgutter

      # InstantRst
      pkgs.instantRstVim

      # vim-instant-markdown
      pkgs.vim-instant-markdown

      # NERDtree
      nerdtree

      # editorconfig
      editorconfig-vim
    ];

    viAlias      = true;
    vimAlias     = true;
    vimdiffAlias = true;

    # for coc.nvim
    withNodeJs = true;

    # for InstantRst
    extraPython3Packages = _: with pkgs; [ instantRstPy smdv ];
  };
}
