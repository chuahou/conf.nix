# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

let
  configLocation = "nvim/copied";
  configDir = "${config.xdg.configHome}/${configLocation}";
in {
  # copy entire nvim configuration directory
  xdg.configFile = {
    ${configLocation}.source = ../res/nvim;
  }

  # copy tree-sitter grammars
  // builtins.foldl' (x: y: x // y) {} (builtins.map
    (lang: {
      "nvim/parser/${lang}.so".source =
        "${pkgs.tree-sitter.builtGrammars."tree-sitter-${lang}"}/parser";
    })
    [ "c" "haskell" ]);

  # copy editorconfig
  home.file.".editorconfig".source = ../res/editorconfig;

  # language servers to be installed
  home.packages = with pkgs; [
    clang-tools haskell-language-server
  ];

  programs.neovim = {
    enable = true;

    package = pkgs.neovim-unwrapped;

    extraConfig = ''
      " faster updates for coc/vim-gitgutter etc
      set updatetime=100

      " we use the full configuration copied
      set runtimepath^=${configDir} runtimepath+=${configDir}/after
      source ${configDir}/init.vim

      "-----------------"
      " nvim-treesitter "
      "-----------------"
      lua <<EOF
        require "nvim-treesitter.configs".setup {
          highlight = { enable = true }
        }
      EOF

      "-------------"
      " vim-airline "
      "-------------"

      let g:airline_theme = 'angr'
      let g:airline#extensions#whitespace#mixed_indent_algo = 2
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

      let g:coc_config_home = "${configDir}"

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
      coc-clangd
      coc-nvim
      nvim-treesitter
      vim-nix
      vim-pandoc-syntax
      vimtex

      # alignment
      tabular

      # vim-airline
      vim-airline
      vim-airline-themes

      # git sign column
      vim-gitgutter

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
  };
}
